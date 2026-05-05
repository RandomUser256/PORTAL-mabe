//
//  chatScreen.swift
//  HealthPoint
//
//  Created by Máximo on 4/14/26.
//
import SwiftUI
import SwiftData
import FoundationModels
import UserNotifications

/// Presents the pharmacy chat interface, manages transcript state, and bridges UI actions to the chat orchestrator.
struct consultaDinamicaScreen: View {
    // Used to call swiftData model actions
    @Environment(\.modelContext) private var modelContext

    // References global environmentObject of current user
    @EnvironmentObject var currentUser: UserSettings

    /// Current text waiting to be sent to the assistant.
    @State private var prompt = ""
    /// Tracks whether the assistant is currently generating a response.
    @State private var isLoading = false
    /// Stores the visible conversation in chronological order for rendering and persistence.
    @State private var conversation: [ChatMessage] = [] // Oldest-first (top)
    /// Indicates whether live speech transcription is in progress.
    @State private var isRecording = false
    /// Switches between concise and more detailed assistant responses.
    @State private var isDetailed = false
    /// User-adjustable font size used for chat bubbles.
    @State private var titleSize: Double = 34
    @State private var textSize: Double = 17

    // Lazily built on first .onAppear so modelContext is available.
    @State private var orchestrator: ChatOrchestrator?
    @State private var hasRequestedNotificationPermission = false
    
    // Feedback popup state
    @State private var showFeedbackPopup = false
    @State private var feedbackMessageId: UUID?
    @State private var feedbackTimer: Task<Void, Never>?

    private let chatBackground = Color(.background)
    private let cardFill = Color(.secondary).opacity(0.55)

    // Simple chat message model for the transcript
    private struct ChatMessage: Identifiable, Equatable, Codable {
        enum Role: String, Codable { case user, assistant }
        let id: UUID
        let role: Role
        let text: String
        let context: [String]?
        var feedbackGiven: Bool = false // Track if feedback was already provided

        init(id: UUID = UUID(), role: Role, text: String, context: [String]?, feedbackGiven: Bool = false) {
            self.id = id
            self.role = role
            self.text = text
            self.context = context
            self.feedbackGiven = feedbackGiven
        }
    }

    // MARK: - Orchestrator factory
    /// Builds the ChatOrchestrator once we have access to the SwiftData ModelContext.
    private func makeOrchestrator(context: ModelContext) -> ChatOrchestrator {
        let retriever = KnowledgeRetriever(sources: [
            EmployeeDatabaseSource(context: context, maxResults: 5),
            DepartmentDatabaseSource(context: context, maxResults: 3),
            RequestDatabaseSource(context: context, maxResults: 5),
            WorkScheduleDatabaseSource(context: context, maxResults: 5)
        ])
        return ChatOrchestrator(retriever: retriever)
    }

    // MARK: - Components
    /// Renders a single message bubble with styling based on whether it belongs to the user or assistant.
    private func bubble(text: String, role: ChatMessage.Role) -> some View {
        let isUser = (role == .user)
        return Text(text)
            .font(.system(size: textSize))
            .foregroundStyle(isUser ? .main : .black)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isUser ? Color(.background).opacity(0.55) : cardFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color(.secondary).opacity(isUser ? 0.9 : 0.55), lineWidth: 1.5)
                    )
            )
            .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
            .accessibilityLabel("\(isUser ? "Tu mensaje" : "Respuesta del asistente"): \(text)")
    }

    /// Builds a reusable circular button for the input toolbar, optionally replacing the icon with a spinner.
    private func circularActionButton(systemName: String, label: String, isLoading: Bool = false) -> some View {
        ZStack {
            Circle()
                .fill(.main)
                .overlay(Circle().stroke(Color(.secondary), lineWidth: 1.5))

            if isLoading {
                ProgressView()
                    .tint(.main)
            } else {
                Image(systemName: systemName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.background)
            }
        }
        .frame(width: 58, height: 58)
        .accessibilityLabel(label)
    }

    private var inputContainer: some ShapeStyle {
        cardFill
    }

    /// Displays the screen title and links into the chat configuration controls.
    private var headerBar: some View {
        HStack {
            Text("Consulta Dinámica")
                .font(.custom("Futura Bold", size: 60))
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.horizontal)
    }

    /// Keeps the newest message visible after loading or appending conversation entries.
    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        guard let lastID = conversation.last?.id else { return }
        withAnimation {
            proxy.scrollTo(lastID, anchor: .bottom)
        }
    }

    // MARK: - Actions
    /// Sends the current prompt to the orchestrator, appends both sides of the exchange, and captures retrieved context.
    private func generate() {
        let query = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty, let orchestrator else { return }

        isLoading = true
        conversation.append(ChatMessage(role: .user, text: query, context: nil))
        prompt = ""

        Task {
            let answer = await orchestrator.answer(userQuery: query, detailed: isDetailed)

            /// Build the complete response with retrieval explanation and context
            var fullResponse = answer.retrievalExplanation + "\n\n" + answer.content
            
            if !answer.usedContext.isEmpty {
                fullResponse += "\n\n📊 Detalles de la base de datos consultada:"
                let contextBlock = answer.usedContext.enumerated()
                    .map { "\n\n[\($0 + 1)] \($1)" }
                    .joined()
                fullResponse += contextBlock
            }

            let assistant = ChatMessage(role: .assistant, text: fullResponse, context: answer.usedContext)
            await MainActor.run {
                self.conversation.append(assistant)
                self.isLoading = false
                
                // Schedule feedback popup for this message
                self.scheduleFeedbackPopup(for: assistant.id)
            }
        }
    }

    // MARK: - Persistence
    /// Persists the current conversation locally under the active user's storage key.
    /*private func saveConversation() {
        do {
            let data = try JSONEncoder().encode(conversation)
            UserDefaults.standard.set(data, forKey: conversationStorageKey())
        } catch { }
    }

    /// Restores the last saved conversation for the active user, if one exists.
    private func loadConversation() {
        guard let data = UserDefaults.standard.data(forKey: conversationStorageKey()) else { return }
        do {
            conversation = try JSONDecoder().decode([ChatMessage].self, from: data)
        } catch { }
    }*/

    /// Clears both the on-screen conversation and its persisted copy.
    private func clearConversation() {
        conversation.removeAll()
        //saveConversation()
        prompt = ""
    }
    
    /// Schedules a feedback popup to appear after a delay
    private func scheduleFeedbackPopup(for messageId: UUID) {
        // Cancel any existing timer
        feedbackTimer?.cancel()
        
        // Schedule new feedback popup after 3 seconds
        feedbackTimer = Task {
            try? await Task.sleep(for: .seconds(3))
            
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                // Only show if feedback hasn't been given yet
                if let message = conversation.first(where: { $0.id == messageId }),
                   !message.feedbackGiven {
                    self.feedbackMessageId = messageId
                    self.showFeedbackPopup = true
                }
            }
        }
    }
    
    /// Saves user feedback to the database
    private func saveFeedback(isPositive: Bool) {
        guard let messageId = feedbackMessageId,
              let assistantMessageIndex = conversation.firstIndex(where: { $0.id == messageId }),
              assistantMessageIndex > 0 else { return }
        
        let assistantMessage = conversation[assistantMessageIndex]
        let userMessage = conversation[assistantMessageIndex - 1]
        
        // Create and save feedback
        let feedback = ChatFeedback(
            userQuery: userMessage.text,
            assistantResponse: assistantMessage.text,
            isPositive: isPositive,
            userId: currentUser.user?.institutional_email,
            contextUsed: assistantMessage.context
        )
        
        modelContext.insert(feedback)
        
        // Mark feedback as given
        conversation[assistantMessageIndex].feedbackGiven = true
        
        // Hide popup
        showFeedbackPopup = false
        feedbackMessageId = nil
    }
    
    /// Feedback popup view
    private var feedbackPopup: some View {
        VStack(spacing: 16) {
            Text("¿Fue útil la información?")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
            
            HStack(spacing: 24) {
                // Thumbs up button
                Button(action: {
                    saveFeedback(isPositive: true)
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "hand.thumbsup.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.green)
                        Text("Sí")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Thumbs up - La información fue útil")
                
                // Thumbs down button
                Button(action: {
                    saveFeedback(isPositive: false)
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "hand.thumbsdown.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.red)
                        Text("No")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Thumbs down - La información no fue útil")
            }
            
            // Dismiss button
            Button(action: {
                showFeedbackPopup = false
                feedbackMessageId = nil
            }) {
                Text("Cerrar")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.background))
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(.secondary).opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 40)
    }

    var body: some View {
        ZStack {
            chatBackground
                .ignoresSafeArea()

            VStack(spacing: 12) {
                headerBar

                /// Conversation view (oldest messages at the top, newest at the bottom)
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(conversation) { message in
                                HStack {
                                    if message.role == .assistant {
                                        bubble(text: message.text, role: .assistant)
                                        Spacer(minLength: 30)
                                    } else {
                                        Spacer(minLength: 30)
                                        bubble(text: message.text, role: .user)
                                    }
                                }
                                .padding(.horizontal)
                                .id(message.id)
                            }
                        }
                        .padding(.top, 4)
                    }
                    .onAppear {
                        if orchestrator == nil { orchestrator = makeOrchestrator(context: modelContext) }
                        if !hasRequestedNotificationPermission {
                            requestNotificationPermission()
                            hasRequestedNotificationPermission = true
                        }
                        //loadConversation()
                        scrollToBottom(proxy)
                    }
                    .onChange(of: conversation.count) { _, _ in
                        scrollToBottom(proxy)
                        //saveConversation()
                    }
                    .scrollDismissesKeyboard(.interactively)
                }

                /// Input area
                HStack(alignment: .bottom, spacing: 8) {
                    TextField("Escribe un mensaje...", text: $prompt, axis: .vertical)
                        .font(.system(size: textSize))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(inputContainer)
                        )
                        .lineLimit(3, reservesSpace: true)
                        .padding()
                        .accessibilityLabel("Campo de mensaje")
                        .accessibilityHint("Escribe la consulta que quieres enviar")

                    Button(action: generate) {
                        ZStack {
                            Image("pm_ECLIPSE_default")
                                .resizable()
                                .scaledToFit()
                                .clipShape(Circle())

                            if isLoading {
                                ProgressView()
                                    .tint(.background)
                            } else {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(.background)
                            }
                        }
                        .frame(width: 58, height: 58)
                        .brightness(prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.3 : 0)
                        .accessibilityLabel("Enviar mensaje")
                    }
                    .disabled(prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                    .buttonStyle(.plain)
                    .accessibilityHint("Envía tu mensaje al asistente")
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .onChange(of: isLoading) { oldValue, newValue in
                if newValue {
                    NotificationManager.shared.notify(event: .chatLoading(prompt: nil))
                }
            }
            /// Loading overlay
            if isLoading {
                /*Color.black.opacity(0.15).ignoresSafeArea()
                ProgressView("Generando respuesta...")
                    .padding(20)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.foreground)))
                    .tint(.universalAccent)*/
            }
            
            // Feedback popup overlay
            if showFeedbackPopup {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showFeedbackPopup = false
                        feedbackMessageId = nil
                    }
                
                feedbackPopup
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showFeedbackPopup)
        .navigationBarBackButtonHidden(false)
    }
}
