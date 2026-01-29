import Cocoa
import SwiftUI
import Combine

class StatusBarManager: ObservableObject {
    var statusItem: NSStatusItem?
    private var clickAction: (() -> Void)?

    /// 设置状态栏图标
    /// - Parameter action: 点击状态栏图标时执行的回调
    func setup(action: @escaping () -> Void) {
        self.clickAction = action

        // 创建状态栏项目
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let statusButton = statusItem?.button {
            statusButton.image = NSImage(systemSymbolName: "eye.circle.fill", accessibilityDescription: "Eye Care")
            statusButton.image?.isTemplate = true
            statusButton.action = #selector(statusBarButtonClicked)
            statusButton.target = self
        }
    }

    /// 更新状态栏图标文字
    /// - Parameters:
    ///   - minutes: 分钟数
    ///   - seconds: 秒数
    func updateIcon(minutes: Int, seconds: Int) {
        guard let statusButton = statusItem?.button else { return }

        if minutes > 0 || seconds > 0 {
            statusButton.title = String(format: "%02d:%02d", minutes, seconds)
        } else {
            statusButton.title = ""
        }
    }

    /// 清除状态栏图标文字
    func clearIcon() {
        statusItem?.button?.title = ""
    }

    @objc private func statusBarButtonClicked() {
        clickAction?()
    }

    deinit {
        // 从状态栏移除
        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
        }
    }
}
