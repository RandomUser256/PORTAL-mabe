//
//  ChatFeedbackAnalyticsView.swift
//  HealthPoint
//
//  Created by Máximo on 5/5/26.
//
import SwiftUI
import SwiftData

/// View to display and analyze chat feedback data
struct ChatFeedbackAnalyticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChatFeedback.timestamp, order: .reverse) private var allFeedback: [ChatFeedback]
    
    @State private var showPositiveOnly = false
    @State private var showNegativeOnly = false
    
    private var filteredFeedback: [ChatFeedback] {
        if showPositiveOnly {
            return allFeedback.filter { $0.isPositive }
        } else if showNegativeOnly {
            return allFeedback.filter { !$0.isPositive }
        }
        return allFeedback
    }
    
    private var positiveCount: Int {
        allFeedback.filter { $0.isPositive }.count
    }
    
    private var negativeCount: Int {
        allFeedback.filter { !$0.isPositive }.count
    }
    
    private var satisfactionRate: Double {
        guard !allFeedback.isEmpty else { return 0 }
        return Double(positiveCount) / Double(allFeedback.count) * 100
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Statistics Header
                VStack(spacing: 16) {
                    Text("Satisfacción del Usuario")
                        .font(.title2.bold())
                    
                    HStack(spacing: 24) {
                        StatCard(
                            icon: "hand.thumbsup.fill",
                            color: .green,
                            count: positiveCount,
                            label: "Positivos"
                        )
                        
                        StatCard(
                            icon: "hand.thumbsdown.fill",
                            color: .red,
                            count: negativeCount,
                            label: "Negativos"
                        )
                        
                        StatCard(
                            icon: "percent",
                            color: .blue,
                            count: Int(satisfactionRate),
                            label: "Satisfacción"
                        )
                    }
                    
                    // Filters
                    HStack(spacing: 12) {
                        FilterButton(
                            title: "Todos",
                            isSelected: !showPositiveOnly && !showNegativeOnly,
                            action: {
                                showPositiveOnly = false
                                showNegativeOnly = false
                            }
                        )
                        
                        FilterButton(
                            title: "Positivos",
                            isSelected: showPositiveOnly,
                            action: {
                                showPositiveOnly = true
                                showNegativeOnly = false
                            }
                        )
                        
                        FilterButton(
                            title: "Negativos",
                            isSelected: showNegativeOnly,
                            action: {
                                showPositiveOnly = false
                                showNegativeOnly = true
                            }
                        )
                    }
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                
                // Feedback List
                List {
                    ForEach(filteredFeedback) { feedback in
                        FeedbackRow(feedback: feedback)
                    }
                    .onDelete(perform: deleteFeedback)
                }
            }
            .navigationTitle("Análisis de Feedback")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func deleteFeedback(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredFeedback[index])
        }
    }
}

// MARK: - Subviews

private struct StatCard: View {
    let icon: String
    let color: Color
    let count: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text("\(count)")
                .font(.title.bold())
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5)
        )
    }
}

private struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.blue : Color(.systemGray5))
                )
        }
        .buttonStyle(.plain)
    }
}

private struct FeedbackRow: View {
    let feedback: ChatFeedback
    @State private var isExpanded = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: feedback.isPositive ? "hand.thumbsup.fill" : "hand.thumbsdown.fill")
                    .foregroundColor(feedback.isPositive ? .green : .red)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(feedback.isPositive ? "Feedback Positivo" : "Feedback Negativo")
                        .font(.headline)
                    
                    Text(dateFormatter.string(from: feedback.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { isExpanded.toggle() }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pregunta del usuario:")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        
                        Text(feedback.userQuery)
                            .font(.body)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Respuesta del asistente:")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        
                        Text(feedback.assistantResponse)
                            .font(.body)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .lineLimit(5)
                    }
                    
                    if let userId = feedback.userId {
                        HStack {
                            Image(systemName: "person.fill")
                                .font(.caption)
                            Text("Usuario: \(userId)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let context = feedback.contextUsed, !context.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Contexto usado: \(context.count) fuentes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    ChatFeedbackAnalyticsView()
        .modelContainer(for: ChatFeedback.self, inMemory: true)
}
