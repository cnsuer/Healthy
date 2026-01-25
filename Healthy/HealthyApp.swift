//
//  HealthyApp.swift
//  Healthy
//
//  Created by Restver on 2026/1/25.
//

import SwiftUI

@main
struct HealthyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // 不需要主窗口，应用运行在状态栏
        Settings {
            EmptyView()
        }
    }
}
