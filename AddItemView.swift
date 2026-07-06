// AddItemView.swift — 新增固定支出/投资项
import SwiftUI
import SwiftData

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var amountText = ""
    @State private var dueDate = Date()
    @State private var category: FinancialCategory = .rent
    @State private var recurrence: RecurrenceType = .monthly

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && Double(amountText) != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("标题（如：房租）", text: $title)
                    TextField("金额", text: $amountText)
                        .keyboardType(.decimalPad)
                    DatePicker("到期日", selection: $dueDate, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "zh_CN"))
                }

                Section("分类") {
                    Picker("分类", selection: $category) {
                        ForEach(FinancialCategory.allCases) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("周期") {
                    Picker("周期", selection: $recurrence) {
                        ForEach(RecurrenceType.allCases) { r in
                            Text(r.displayName).tag(r)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("新增事项")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(!isValid)
                        .fontWeight(.semibold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func save() {
        guard let amount = Double(amountText) else { return }
        let item = FinancialItem(
            title: title.trimmingCharacters(in: .whitespaces),
            amount: amount,
            dueDate: dueDate,
            category: category,
            recurrence: recurrence
        )
        modelContext.insert(item)
        NotificationManager.schedule(for: item)
        dismiss()
    }
}
