// SettingsView.swift — 设置：允许用户自行关闭 Face ID 锁定
import SwiftUI

struct SettingsView: View {
    @AppStorage("lockEnabled") private var lockEnabled = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    Toggle(isOn: $lockEnabled) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Face ID 锁定")
                                .font(.system(.body, design: .rounded).weight(.semibold))
                                .foregroundStyle(.white)
                            Text("打开 App 或回到前台时需要验证身份")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                    .tint(.teal)
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))

                    Spacer()
                }
                .padding(16)
                .padding(.top, 12)
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
