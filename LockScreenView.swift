// LockScreenView.swift — 应用启动 / 回到前台时强制 FaceID 验证
import SwiftUI
import LocalAuthentication

struct LockScreenView: View {
    @AppStorage("lockEnabled") private var lockEnabled = true
    @State private var isUnlocked = false
    @State private var authError: String?
    @State private var isAuthenticating = false

    var body: some View {
        ZStack {
            if isUnlocked || !lockEnabled {
                DashboardView()
                    .transition(.opacity)
            } else {
                lockOverlay
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isUnlocked)
        .onAppear {
            if lockEnabled { authenticate() }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            if lockEnabled { isUnlocked = false }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            if lockEnabled && !isUnlocked { authenticate() }
        }
        .onChange(of: lockEnabled) { _, newVal in
            if !newVal { isUnlocked = true }
        }
    }

    private var lockOverlay: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [Color.teal, Color.mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 88, height: 88)
                        .shadow(color: Color.teal.opacity(0.4), radius: 16, x: 0, y: 8)
                    Image(systemName: biometricIcon)
                        .font(.system(size: 40))
                        .foregroundStyle(.white)
                }

                VStack(spacing: 8) {
                    Text("本地账单")
                        .font(.system(.title, design: .rounded).bold())
                        .foregroundStyle(.white)
                    Text("需要验证身份才能访问")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }

                if let error = authError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Spacer()

                Button { authenticate() } label: {
                    HStack(spacing: 10) {
                        Image(systemName: biometricIcon).font(.title3)
                        Text(isAuthenticating ? "验证中..." : biometricLabel).fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(colors: [Color.teal, Color.mint], startPoint: .leading, endPoint: .trailing)
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.teal.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 40)
                .disabled(isAuthenticating)
                .padding(.bottom, 60)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var biometricIcon: String {
        let ctx = LAContext()
        var error: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else { return "lock.fill" }
        switch ctx.biometryType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        default: return "lock.fill"
        }
    }

    private var biometricLabel: String {
        let ctx = LAContext()
        var error: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else { return "未设置 Face ID" }
        switch ctx.biometryType {
        case .faceID: return "Face ID 解锁"
        case .touchID: return "Touch ID 解锁"
        default: return "未设置 Face ID"
        }
    }

    private func authenticate() {
        isAuthenticating = true
        authError = nil
        let ctx = LAContext()
        var error: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            authError = "未设置 Face ID，请到系统设置中开启"
            isAuthenticating = false
            return
        }
        ctx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "验证身份以访问本地账单") { success, err in
            DispatchQueue.main.async {
                isAuthenticating = false
                if success {
                    withAnimation { isUnlocked = true }
                } else if let e = err as? LAError {
                    switch e.code {
                    case .userCancel, .appCancel:
                        authError = "已取消，点击按钮重试"
                    case .biometryLockout:
                        authError = "Face ID 已锁定，请解锁设备后重试"
                    default:
                        authError = "验证失败，请重试"
                    }
                }
            }
        }
    }
}
