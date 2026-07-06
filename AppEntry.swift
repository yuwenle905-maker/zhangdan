// AppEntry.swift — App 入口 + SwiftData 容器（App Group 容器，预留 Widget 共享数据）
import SwiftUI
import SwiftData

@main
struct 本地账单App: App {
    let container: ModelContainer = ModelContainerFactory.make()

    init() {
        NotificationManager.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            LockScreenView()
                .modelContainer(container)
                .preferredColorScheme(.dark)
        }
    }
}
