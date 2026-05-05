import Foundation
import UserNotifications

// General-purpose notification manager for app-wide use.
final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    // Request authorization once (call early in app lifecycle).
    func requestAuthorization(options: UNAuthorizationOptions = [.alert, .sound, .badge], completion: ((Bool, Error?) -> Void)? = nil) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: options) { granted, error in
            completion?(granted, error)
            if let error = error {
                print("Notification authorization error: \(error)")
            }
        }
    }

    // Send a notification now (no trigger)
    func notifyNow(title: String, body: String, identifier: String = UUID().uuidString, sound: UNNotificationSound = .default) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error delivering notification: \(error)")
            }
        }
    }

    // Send after a delay in seconds
    func notify(title: String, body: String, after delay: TimeInterval, identifier: String = UUID().uuidString, sound: UNNotificationSound = .default) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(0.1, delay), repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    // Schedule at a specific date
    func notify(at date: Date, title: String, body: String, identifier: String = UUID().uuidString, sound: UNNotificationSound = .default) {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling calendar notification: \(error)")
            }
        }
    }

    // Typed events for convenience and future expansion
    enum AppEvent {
        case chatLoading(prompt: String?)
        case chatResponseReady
        case custom(title: String, body: String)
    }

    func notify(event: AppEvent) {
        switch event {
        case .chatLoading(let prompt):
            let body = prompt.map { "Procesando: \($0)" } ?? "El asistente está generando una respuesta."
            notifyNow(title: "Generando respuesta", body: body)
        case .chatResponseReady:
            notifyNow(title: "Respuesta lista", body: "Tu respuesta del asistente está disponible.")
        case .custom(let title, let body):
            notifyNow(title: title, body: body)
        }
    }

    // Optional: Present notifications while app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }
}

// MARK: - Backwards-compatible free functions

func requestNotificationPermission() {
    NotificationManager.shared.requestAuthorization()
}

@available(*, deprecated, message: "Use NotificationManager.shared.notify(title:body:after:) or notifyNow(title:body:) instead.")
func scheduleLocalNotification() {
    // Preserve old behavior: schedule a notification after 5 seconds with default text
    NotificationManager.shared.notify(title: "Time's Up!", body: "This is a notification sent from your app.", after: 5, identifier: "MyNotification")
}

// Overloads that accept specific strings as requested
func scheduleLocalNotification(title: String, body: String, after delay: TimeInterval = 0) {
    if delay <= 0 {
        NotificationManager.shared.notifyNow(title: title, body: body)
    } else {
        NotificationManager.shared.notify(title: title, body: body, after: delay)
    }
}
