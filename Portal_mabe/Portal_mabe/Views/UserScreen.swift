import SwiftUI

struct userScreen: View {
    @EnvironmentObject var currentUser: UserSettings
    @State private var showNotifications = false

    private var displayName: String {
        [currentUser.user?.name ?? "Juan", currentUser.user?.middleName ?? "Carlos"]
            .joined(separator: " ")
    }

    private var displayID: String {
        "ID: \(currentUser.user?.id_employee ?? 10452)"
    }

    private var displayRole: String {
        currentUser.user?.employee_role.name ?? "Analista de Recursos"
    }
    
    private static let dayNames = ["", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    private var displayJornada: [(day: String, hours: String)] {
        if let workdays = currentUser.user?.workdays, !workdays.isEmpty {
            return workdays
                .sorted { $0.weekDay < $1.weekDay }
                .map { wd in
                    let day = (1...7).contains(wd.weekDay) ? Self.dayNames[wd.weekDay] : "Día \(wd.weekDay)"
                    let hours = "\(Self.timeFormatter.string(from: wd.startTime)) - \(Self.timeFormatter.string(from: wd.endTime))"
                    return (day, hours)
                }
        } else {
            return [
                ("Lunes", "08:00 - 17:00"),
                ("Martes", "08:00 - 17:00"),
                ("Miércoles", "08:00 - 17:00"),
                ("Jueves", "08:00 - 17:00"),
                ("Viernes", "08:00 - 15:00")
            ]
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Perfil")
                        .font(.custom("Futura Bold", size: 80))
                        .foregroundColor(.main)

                    Image("pm_PerfilData")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .overlay {
                            GeometryReader { geo in
                                HStack(spacing: 0) {
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: geo.size.height * 0.4, height: geo.size.height * 0.4)
                                        .foregroundColor(.gray)
                                        .frame(width: geo.size.height * 0.85, height: geo.size.height * 0.85)
                                        .background(Color(.secondary))
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))

                                    VStack(alignment: .leading, spacing: geo.size.height * 0.22) {
                                        Text(displayName)
                                            .font(.custom("Frutiger LT Std 55 Roman", size: 50))
                                            .padding(.horizontal)
                                            .foregroundColor(.white)

                                        Text(displayID)
                                            .font(.custom("Frutiger LT Std 55 Roman", size: 50))
                                            .padding(.horizontal)
                                            .foregroundColor(.white.opacity(0.85))
                                    }
                                    .padding(.leading, geo.size.width * 0.03)
                                }
                                .padding(.leading, geo.size.width * 0.015)
                                .frame(height: geo.size.height, alignment: .leading)
                            }
                        }

                    Image("pm_CTA")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .overlay {
                            GeometryReader { geo in
                                Text(displayRole)
                                    .font(.system(size: geo.size.height * 0.2, weight: .semibold))
                                    .foregroundColor(.main)
                                    .padding(.leading, geo.size.width * 0.06)
                                    .frame(width: geo.size.width, height: geo.size.height, alignment: .leading)
                            }
                        }
                    Text("Registro Jornada")
                        .font(.custom("Frutiger LT Std 65 Bold", size: 50))
                        .foregroundColor(.main)
                        .padding(.leading)
                    Image("pm_Desglose_Registro")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .overlay {
                            GeometryReader { geo in
                                let fontSize = geo.size.height / CGFloat(max(displayJornada.count, 1)) * 0.55
                                VStack(alignment: .leading, spacing: geo.size.height * 0.02) {
                                    ForEach(Array(displayJornada.enumerated()), id: \.offset) { _, entry in
                                        HStack {
                                            Text(entry.day)
                                                .fontWeight(.semibold)
                                            Spacer()
                                            Text(entry.hours)
                                        }
                                        .font(.system(size: fontSize))
                                        .foregroundColor(.main)
                                    }
                                }
                                .padding(.horizontal, geo.size.width * 0.06)
                                .padding(.vertical, geo.size.height * 0.08)
                                .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
                            }
                        }
                    Text("Nóminas")
                        .font(.custom("Frutiger LT Std 65 Bold", size: 50))
                        .foregroundColor(.main)
                        .padding(.leading)
                    Button {
                        // TODO: Add functionality
                    } label: {
                        Image("pm_CTA_Boton")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    .buttonStyle(.plain)
                    .padding()
                }
                .padding(.horizontal)
                

            }
            .toolbar {
                ToolbarItem {
                    Button {
                        showNotifications.toggle()
                        if showNotifications {
                            NotificationStore.shared.markAllAsRead()
                        }
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            ZStack {
                                Image("pm_ICON_NOTIF")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                            //.frame(width: 58, height: 58)
                            .accessibilityLabel("Notificaciones")
                            if NotificationStore.shared.unreadCount > 0 {
                                Text("\(NotificationStore.shared.unreadCount)")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.main)
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
            .padding(.horizontal, 30)
        }
        .background(Color(.background))
    }
}

#Preview {
    userScreen()
}
