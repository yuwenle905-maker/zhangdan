// DashboardView.swift — 主看板：本月汇总 + 到期时间轴 + 悬浮添加按钮
import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FinancialItem.dueDate, order: .forward) private var items: [FinancialItem]

    @State private var showingAddSheet = false
    @State private var selectedItem: FinancialItem?

    private var calendar: Calendar { .current }

    private var itemsThisMonth: [FinancialItem] {
        items.filter { calendar.isDate($0.dueDate, equalTo: Date(), toGranularity: .month) }
    }

    private var totalDue: Double {
        itemsThisMonth
            .filter { !$0.category.isInvestment && !$0.isPaid }
            .reduce(0) { $0 + $1.amount }
    }

    private var totalInvested: Double {
        itemsThisMonth
            .filter { $0.category.isInvestment && $0.isPaid }
            .reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    summaryRow
                    timeline
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 100)
            }

            addButton
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingAddSheet) {
            AddItemView()
        }
        .sheet(item: $selectedItem) { item in
            ItemDetailView(item: item)
        }
    }

    private var summaryRow: some View {
        HStack(spacing: 12) {
            SummaryCard(title: "本月待付总额", amount: totalDue, tint: .red)
            SummaryCard(title: "总投资额", amount: totalInvested, tint: .green)
        }
    }

    private var timeline: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                TimelineRow(item: item, isLast: index == items.count - 1)
                    .onTapGesture { selectedItem = item }
            }

            if items.isEmpty {
                emptyState
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.3))
            Text("暂无待办事项，点击右下角 + 添加")
                .font(.system(.callout, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    private var addButton: some View {
        Button {
            showingAddSheet = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(
                    LinearGradient(colors: [Color.teal, Color.mint], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(Circle())
                .shadow(color: Color.teal.opacity(0.5), radius: 12, x: 0, y: 6)
        }
        .padding(.trailing, 24)
        .padding(.bottom, 32)
    }
}

private struct SummaryCard: View {
    let title: String
    let amount: Double
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
            Text("¥\(String(format: "%.2f", amount))")
                .font(.system(.title2, design: .rounded).bold())
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}

private struct TimelineRow: View {
    let item: FinancialItem
    let isLast: Bool

    private var tint: Color { item.category.isInvestment ? .green : .red }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                Circle()
                    .fill(tint)
                    .frame(width: 10, height: 10)
                    .padding(.top, 6)
                if !isLast {
                    Rectangle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 2)
                }
            }
            .frame(width: 10)

            card
                .padding(.bottom, 16)
        }
    }

    private var card: some View {
        HStack(spacing: 14) {
            Image(systemName: item.category.icon)
                .font(.system(size: 18))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(tint.opacity(0.15), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white)
                    .strikethrough(item.isPaid)
                Text("\(item.category.rawValue) · \(dueDateText)")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("¥\(String(format: "%.2f", item.amount))")
                    .font(.system(.body, design: .rounded).bold())
                    .foregroundStyle(tint)
                if item.isPaid {
                    Label("已完成", systemImage: "checkmark.circle.fill")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.white.opacity(0.4))
                        .labelStyle(.iconOnly)
                }
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(tint.opacity(item.isPaid ? 0 : 0.25), lineWidth: 1)
        )
        .opacity(item.isPaid ? 0.5 : 1)
    }

    private var dueDateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: item.dueDate)
    }
}
