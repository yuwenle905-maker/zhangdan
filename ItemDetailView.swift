// ItemDetailView.swift — 详情弹窗：标记完成后自动滚动到下一周期
import SwiftUI
import SwiftData

struct ItemDetailView: View {
    @Bindable var item: FinancialItem
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var showingDeleteConfirm = false

    private var tint: Color { item.category.isInvestment ? .green : .red }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 24) {
                    header

                    VStack(spacing: 0) {
                        detailRow(label: "分类", value: item.category.rawValue)
                        Divider().background(Color.white.opacity(0.1))
                        detailRow(label: "金额", value: "¥\(String(format: "%.2f", item.amount))")
                        Divider().background(Color.white.opacity(0.1))
                        detailRow(label: "到期日", value: dueDateText)
                        Divider().background(Color.white.opacity(0.1))
                        detailRow(label: "周期", value: item.recurrence.displayName)
                        Divider().background(Color.white.opacity(0.1))
                        detailRow(label: "状态", value: item.isPaid ? "已完成" : "待处理")
                    }
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))

                    Spacer()

                    Button {
                        markCompleted()
                    } label: {
                        Text(item.isPaid ? "已完成，等待下一周期" : "标记为已完成")
                            .font(.system(.body, design: .rounded).bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(tint.opacity(item.isPaid ? 0.3 : 1))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Button(role: .destructive) {
                        showingDeleteConfirm = true
                    } label: {
                        Text("删除")
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(.red)
                    }
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
            }
            .confirmationDialog("确认删除该事项？", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
                Button("删除", role: .destructive) {
                    NotificationManager.cancel(for: item)
                    modelContext.delete(item)
                    dismiss()
                }
                Button("取消", role: .cancel) {}
            }
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: item.category.icon)
                .font(.system(size: 32))
                .foregroundStyle(tint)
                .frame(width: 64, height: 64)
                .background(tint.opacity(0.15), in: Circle())
            Text(item.title)
                .font(.system(.title2, design: .rounded).bold())
                .foregroundStyle(.white)
        }
        .padding(.top, 12)
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
            Spacer()
            Text(value)
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var dueDateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: item.dueDate)
    }

    private func markCompleted() {
        guard !item.isPaid else { return }
        item.isPaid = true
        item.dueDate = item.recurrence.nextDate(after: item.dueDate)
        item.isPaid = false
        NotificationManager.schedule(for: item)
        dismiss()
    }
}
