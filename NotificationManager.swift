// NotificationManager.swift — 本地推送：提前 3 天 + 到期当日提醒
import Foundation
import UserNotifications

enum NotificationManager {
    static func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    /// 为该条目安排两条提醒；同一 id 前缀的旧提醒会先被清除，避免重复堆积
    static func schedule(for item: FinancialItem) {
        cancel(for: item)
        guard !item.isPaid else { return }

        let center = UNUserNotificationCenter.current()
        let calendar = Calendar.current

        if let threeDaysBefore = calendar.date(byAdding: .day, value: -3, to: item.dueDate),
           threeDaysBefore > Date() {
            let content = makeContent(
                title: "还款提醒：\(item.title)",
                body: "\(item.category.rawValue) · ¥\(formatted(item.amount)) 将于 3 天后到期，请提前筹措资金"
            )
            addRequest(center: center, identifier: reminderId(item, suffix: "3d"), date: threeDaysBefore, content: content)
        }

        if item.dueDate > Date() {
            let content = makeContent(
                title: "今日到期：\(item.title)",
                body: "\(item.category.rawValue) · ¥\(formatted(item.amount)) 今天到期，请及时处理"
            )
            addRequest(center: center, identifier: reminderId(item, suffix: "due"), date: item.dueDate, content: content)
        }
    }

    static func cancel(for item: FinancialItem) {
        let ids = [reminderId(item, suffix: "3d"), reminderId(item, suffix: "due")]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    private static func makeContent(title: String, body: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        return content
    }

    private static func addRequest(center: UNUserNotificationCenter, identifier: String, date: Date, content: UNMutableNotificationContent) {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request)
    }

    private static func reminderId(_ item: FinancialItem, suffix: String) -> String {
        "\(item.id.uuidString)-\(suffix)"
    }

    private static func formatted(_ amount: Double) -> String {
        String(format: "%.2f", amount)
    }
}
