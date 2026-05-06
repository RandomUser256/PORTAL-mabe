import SwiftUI

struct UserNotifView: View {
    var store: NotificationStore = .shared

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Notificaciones")
                .font(.headline)
                .padding()

            Divider()

            if store.notifications.isEmpty {
                Text("No hay notificaciones")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(store.notifications) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(item.title)
                                        .font(.subheadline.weight(.semibold))
                                    Spacer()
                                    if !item.isRead {
                                        Circle()
                                            .fill(.blue)
                                            .frame(width: 8, height: 8)
                                    }
                                }
                                Text(item.body)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                Text(item.date, style: .relative)
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)

                            Divider()
                        }
                    }
                }
                .frame(maxHeight: 300)
            }
        }
        .frame(width: 280)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
    }
}

#Preview {
    UserNotifView(store: {
        let store = NotificationStore()
        store.add(title: "Respuesta lista", body: "Tu respuesta del asistente está disponible.")
        store.add(title: "Solicitud aprobada", body: "Tu solicitud de vacaciones ha sido aprobada por tu supervisor.")
        return store
    }())
}
