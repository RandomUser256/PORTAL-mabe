//
//  FeedbackPopupPreview.swift
//  HealthPoint
//
//  Created by Máximo on 5/5/26.
//
import SwiftUI

/// Standalone preview of the feedback popup for design reference
struct FeedbackPopupPreview: View {
    @State private var showPopup = true
    
    var body: some View {
        ZStack {
            // Background chat (simulated)
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Chat conversation here...")
                    .foregroundColor(.secondary)
                
                Button("Show Feedback Popup") {
                    showPopup = true
                }
                .buttonStyle(.borderedProminent)
            }
            
            // Feedback popup
            if showPopup {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showPopup = false
                    }
                
                VStack(spacing: 16) {
                    Text("¿Fue útil la información?")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                    
                    HStack(spacing: 24) {
                        // Thumbs up button
                        Button(action: {
                            print("Thumbs up!")
                            showPopup = false
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
                        
                        // Thumbs down button
                        Button(action: {
                            print("Thumbs down!")
                            showPopup = false
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
                    }
                    
                    // Dismiss button
                    Button(action: {
                        showPopup = false
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
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal, 40)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showPopup)
    }
}

#Preview {
    FeedbackPopupPreview()
}
