import SwiftUI

struct userScreen: View {
    @EnvironmentObject var currentUser: UserSettings
    @State private var showNotifications = false
    @State private var checkedTimes: Set<String> = []

    private var displayName: String {
        [currentUser.user?.name ?? "Nombre", currentUser.user?.middleName ?? "Apellido"]
            .joined(separator: " ")
    }

    private var displayID: String {
        "ID: \(currentUser.user?.id_employee ?? 0000)"
    }

    private var displayRole: String {
        currentUser.user?.employee_role.name ?? "Sin Ról"
    }
    
    private static let dayNames = ["", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    private var displayJornada: [(day: String, startTime: String, endTime: String)] {
        if let workdays = currentUser.user?.workdays, !workdays.isEmpty {
            return workdays
                .sorted { $0.weekDay < $1.weekDay }
                .map { wd in
                    let day = (1...7).contains(wd.weekDay) ? Self.dayNames[wd.weekDay] : "Día \(wd.weekDay)"
                    let start = Self.timeFormatter.string(from: wd.startTime)
                    let end = Self.timeFormatter.string(from: wd.endTime)
                    return (day, start, end)
                }
        } else {
            return [
                ("Lunes", "08:00", "17:00"),
                ("Martes", "08:00", "17:00"),
                ("Miércoles", "08:00", "17:00"),
                ("Jueves", "08:00", "17:00"),
                ("Viernes", "08:00", "15:00")
            ]
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Perfil")
                        .font(.custom("Futura Bold", size: 60))
                        .foregroundColor(.black)

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
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(displayJornada.enumerated()), id: \.offset) { _, entry in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.day)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.main)
                                    .padding(.leading, 4)

                                HStack(spacing: 0) {
                                    Image("pm_CTA")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .overlay {
                                            GeometryReader { ctaGeo in
                                                HStack(spacing: ctaGeo.size.width * 0.03) {
                                                    Button {
                                                        let key = "\(entry.day)-start"
                                                        if checkedTimes.contains(key) {
                                                            checkedTimes.remove(key)
                                                        } else {
                                                            checkedTimes.insert(key)
                                                        }
                                                    } label: {
                                                        Image(checkedTimes.contains("\(entry.day)-start") ? "pm_ECLIPSE_default" : "pm_ECLIPSE_ring")
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(height: ctaGeo.size.height * 0.5)
                                                    }
                                                    .buttonStyle(.plain)

                                                    Text("Check-in: ")
                                                        .font(.system(size: ctaGeo.size.height * 0.35, weight: .medium))
                                                        .foregroundColor(.main)
                                                    Text(entry.startTime)
                                                        .font(.system(size: ctaGeo.size.height * 0.35, weight: .medium))
                                                        .foregroundColor(.main)
                                                }
                                                .padding(.leading, ctaGeo.size.width * 0.06)
                                                .frame(width: ctaGeo.size.width, height: ctaGeo.size.height, alignment: .leading)
                                            }
                                        }

                                    Image("pm_CTA")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .overlay {
                                            GeometryReader { ctaGeo in
                                                HStack(spacing: ctaGeo.size.width * 0.03) {
                                                    Button {
                                                        let key = "\(entry.day)-end"
                                                        if checkedTimes.contains(key) {
                                                            checkedTimes.remove(key)
                                                        } else {
                                                            checkedTimes.insert(key)
                                                        }
                                                    } label: {
                                                        Image(checkedTimes.contains("\(entry.day)-end") ? "pm_ECLIPSE_default" : "pm_ECLIPSE_ring")
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(height: ctaGeo.size.height * 0.5)
                                                    }
                                                    .buttonStyle(.plain)

                                                    Text("Check-out: ")
                                                        .font(.system(size: ctaGeo.size.height * 0.35, weight: .medium))
                                                        .foregroundColor(.main)
                                                    Text(entry.endTime)
                                                        .font(.system(size: ctaGeo.size.height * 0.35, weight: .medium))
                                                        .foregroundColor(.main)
                                                }
                                                .padding(.leading, ctaGeo.size.width * 0.06)
                                                .frame(width: ctaGeo.size.width, height: ctaGeo.size.height, alignment: .leading)
                                            }
                                        }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .background {
                        Image("pm_Desglose_Registro")
                            .resizable()
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
                                    .aspectRatio(contentMode: .fill)
                            }
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
