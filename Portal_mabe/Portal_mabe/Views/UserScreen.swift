import SwiftUI

struct userScreen: View {
    @State private var showNotifications = false

    private func circularActionButton(systemName: String, label: String) -> some View {
        ZStack {
            Circle()
                .fill(.main)
                .overlay(Circle().stroke(Color(.secondary), lineWidth: 1.5))
                Image(systemName: systemName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.background)
        }
        .frame(width: 58, height: 58)
        .accessibilityLabel(label)
    }

    var body: some View {
        NavigationStack {
            Text("Perfil")
                .toolbar {
                    ToolbarItem {
                        Button {
                            showNotifications.toggle()
                            if showNotifications {
                                NotificationStore.shared.markAllAsRead()
                            }
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                circularActionButton(
                                    systemName: "bell",
                                    label: "Notificaciones"
                                )
                                if NotificationStore.shared.unreadCount > 0 {
                                    Text("\(NotificationStore.shared.unreadCount)")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(.white)
                                        .padding(4)
                                        .background(.red, in: Circle())
                                        .offset(x: 4, y: -4)
                                }
                            }
                        }
                        .popover(isPresented: $showNotifications) {
                            UserNotifView()
                                .presentationCompactAdaptation(.popover)
                        }
                    }
                }
        }
    }
}

#Preview {
    userScreen()
}
