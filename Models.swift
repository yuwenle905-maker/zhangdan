// Models.swift — 数据模型 + SwiftData 容器配置
import Foundation
import SwiftData

enum FinancialCategory: String, Codable, CaseIterable, Identifiable {
    case creditCard = "信用卡"
    case huabei = "花呗"
    case childSupport = "抚养费"
    case rent = "房租"
    case investment = "投资"

    var id: String { rawValue }

    /// 投资类为绿色卡片，其余为待还款红色卡片
    var isInvestment: Bool { self == .investment }

    var icon: String {
        switch self {
        case .creditCard: return "creditcard.fill"
        case .huabei: return "yensign.circle.fill"
        case .childSupport: return "figure.2.and.child.holdinghands"
        case .rent: return "house.fill"
        case .investment: return "chart.line.uptrend.xyaxis"
        }
    }
}

enum RecurrenceType: String, Codable, CaseIterable, Identifiable {
    case monthly = "Monthly"
    case weekly = "Weekly"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .monthly: return "每月"
        case .weekly: return "每周"
        }
    }

    /// 从给定日期推算下一周期的同一到期日
    func nextDate(after date: Date, calendar: Calendar = .current) -> Date {
        switch self {
        case .monthly: return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        case .weekly: return calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
        }
    }
}

@Model
final class FinancialItem {
    var id: UUID
    var title: String
    var amount: Double
    var dueDate: Date
    var categoryRaw: String
    var isPaid: Bool
    var recurrenceRaw: String

    init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        dueDate: Date,
        category: FinancialCategory,
        isPaid: Bool = false,
        recurrence: RecurrenceType = .monthly
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.dueDate = dueDate
        self.categoryRaw = category.rawValue
        self.isPaid = isPaid
        self.recurrenceRaw = recurrence.rawValue
    }

    var category: FinancialCategory {
        get { FinancialCategory(rawValue: categoryRaw) ?? .rent }
        set { categoryRaw = newValue.rawValue }
    }

    var recurrence: RecurrenceType {
        get { RecurrenceType(rawValue: recurrenceRaw) ?? .monthly }
        set { recurrenceRaw = newValue.rawValue }
    }
}

enum AppGroup {
    /// 与未来 Widget Extension 共享的 App Group 标识
    static let identifier = "group.com.yourname.zhangdan"
}

enum ModelContainerFactory {
    /// 使用 App Group 容器创建 ModelContainer，便于后续 Widget 直接读取同一份数据
    static func make() -> ModelContainer {
        let schema = Schema([FinancialItem.self])
        let configuration = ModelConfiguration(schema: schema, groupContainer: .identifier(AppGroup.identifier))
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("SwiftData 初始化失败: \(error)")
        }
    }
}
