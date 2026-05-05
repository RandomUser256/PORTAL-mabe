//
//  LoginView.swift
//  PORTAL mape
//
//  Created by Máximo Magallanes Urtuzuástegui on 05/05/26.
//
import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.modelContext) private var modelContext

    let onAuthenticated: (Employee) -> Void

    // Current selected language
    @State private var selectedLanguage: String = "Español"
    
    @State private var collaboratorCode: String = ""
    @State private var authenticationError: String?
    
    
    // Available languages for the dropdown menu
    let languages = ["English", "Español", "Português"]
    
    // Custom colors for the gradient
    let mabeCyan = Color(red: 0.0, green: 0.69, blue: 0.94) // Approximated cyan from logo
    let mabeDarkBlue = Color(red: 0.0, green: 0.2, blue: 0.4) // Approximated dark blue for gradient
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height

            ZStack {
                Image("kitchen_background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()

                Color.black.opacity(0.1)

                ScrollView {
                    VStack(spacing: 0) {
                        HStack {
                            Image("mabe_name")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: max(geometry.size.height * 0.03, 18))

                            Spacer()

                            Menu {
                                ForEach(languages, id: \.self) { language in
                                    Button(action: {
                                        selectedLanguage = language
                                    }) {
                                        Text(language)
                                    }
                                }
                            } label: {
                                HStack(spacing: 5) {
                                    Text(selectedLanguage)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)

                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        .padding(.horizontal, geometry.size.width * 0.06)
                        .padding(.top, 10)

                        Spacer(minLength: isLandscape ? 20 : 0)

                        VStack(spacing: 12) {
                            MabePillButton(text: "Selecciona tu continente", gradient: LinearGradient(colors: [mabeCyan, mabeDarkBlue], startPoint: .topLeading, endPoint: .bottomTrailing))

                            MabePillButton(text: "Selecciona tu país", gradient: LinearGradient(colors: [mabeCyan, mabeDarkBlue], startPoint: .topLeading, endPoint: .bottomTrailing))

                            MabePillButton(text: "Selecciona tu sucursal", gradient: LinearGradient(colors: [mabeCyan, mabeDarkBlue], startPoint: .topLeading, endPoint: .bottomTrailing))

                            VStack(spacing: 10) {
                                MabePillTextField(
                                    gradient: LinearGradient(colors: [.white, .init(white: 0.9)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                    collaboratorCode: $collaboratorCode,
                                    onSubmit: authenticate
                                )

                                Button(action: authenticate) {
                                    Text("Ingresar")
                                        .font(.callout.weight(.semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 28)
                                        .background(
                                            LinearGradient(
                                                colors: [mabeDarkBlue, mabeCyan],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)

                                if let authenticationError {
                                    Text(authenticationError)
                                        .font(.footnote)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }
                        .frame(maxWidth: isLandscape ? min(geometry.size.width * 0.5, 500) : geometry.size.width * 0.88)
                        .padding(.bottom, 20)
                    }
                    .frame(minHeight: geometry.size.height)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .ignoresSafeArea()
        .onTapGesture {
            hideKeyboard()
        }
    }

    private func authenticate() {
        authenticationError = nil

        guard let employeeID = Int(collaboratorCode.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            authenticationError = "Ingresa un número de colaborador válido."
            return
        }

        let descriptor = FetchDescriptor<Employee>(
            predicate: #Predicate { employee in
                employee.id_employee == employeeID
            }
        )

        do {
            if let employee = try modelContext.fetch(descriptor).first {
                onAuthenticated(employee)
            } else {
                authenticationError = "No se encontró un colaborador con ese número."
            }
        } catch {
            authenticationError = "No fue posible autenticar en este momento."
        }
    }
}

// MARK: - Reusable Pill Button Component
// This component recreates the visual style of the pill-shaped buttons and inputs.
struct MabePillButton: View {
    var text: String
    var gradient: LinearGradient
    var textOpacity: Double = 1.0 // Text opacity for the input field-like element

    var body: some View {
        Text(text)
            .font(.callout)
            .foregroundColor(.white)
            .opacity(textOpacity)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 28)
            .background(gradient)
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 3)
            .overlay(
                // Subtle white glow element to mimic the original's soft light
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .blur(radius: 20)
                    .frame(height: 20)
                    .offset(y: -10),
                alignment: .top
            )
    }
}

struct MabePillTextField: View {
    //var text: String
    var gradient: LinearGradient
    var textOpacity: Double = 1.0 // Text opacity for the input field-like element
    
    @Binding var collaboratorCode: String
    let onSubmit: () -> Void

    var body: some View {
        TextField("Ingresa tu número de colaborador..", text: $collaboratorCode)
            .font(.callout)
            .foregroundColor(.black)
            .opacity(textOpacity)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 28)
            .background(gradient)
            .clipShape(Capsule())
            .keyboardType(.numberPad)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.go)
            .onSubmit(onSubmit)
            .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 3)
            .overlay(
                // Subtle white glow element to mimic the original's soft light
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .blur(radius: 20)
                    .frame(height: 20)
                    .offset(y: -10),
                alignment: .top
            )
    }
}

// Preview provider for canvas visualization
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView { _ in }
    }
}

#Preview {
    LoginView { _ in }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
