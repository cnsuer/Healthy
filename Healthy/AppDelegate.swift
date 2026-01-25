import Cocoa
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var viewModel: EyeCareViewModel?
    var popover: NSPopover?
    var fullScreenWindow: FullScreenWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 创建ViewModel
        let viewModel = EyeCareViewModel()
        self.viewModel = viewModel

        // 创建状态栏项目
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let statusButton = statusItem?.button {
            statusButton.image = NSImage(systemSymbolName: "eye.circle.fill", accessibilityDescription: "Eye Care")
            statusButton.image?.isTemplate = true
            statusButton.action = #selector(statusBarButtonClicked)
            statusButton.target = self
        }

        // 创建弹出菜单
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 300, height: 500)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(
            rootView: EyeCareMenuView(viewModel: viewModel)
        )

        // 监听全屏显示变化
        viewModel.$showFullScreen
            .receive(on: RunLoop.main)
            .sink { [weak self] show in
                if show {
                    self?.showFullScreen()
                } else {
                    self?.hideFullScreen()
                }
            }
            .store(in: &cancellables)

        // 监听倒计时更新以更新状态栏图标
        viewModel.$remainingTime
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusBarIcon()
            }
            .store(in: &cancellables)

        // 监听启用状态变化
        viewModel.settings.$isEnabled
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusBarIcon()
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    @objc func statusBarButtonClicked() {
        guard let statusButton = statusItem?.button else { return }

        if let popover = popover, popover.isShown {
            popover.performClose(nil)
        } else {
            popover?.show(relativeTo: statusButton.bounds, of: statusButton, preferredEdge: .minY)
        }
    }

    private func showFullScreen() {
        // 关闭弹出菜单
        popover?.performClose(nil)

        // 如果窗口已存在，直接返回
        guard fullScreenWindow == nil,
              let viewModel = viewModel else { return }

        // 创建全屏窗口
        let fullScreenView = FullScreenReminderView(viewModel: viewModel)
        let window = FullScreenWindow(contentView: fullScreenView)

        // 显示窗口
        window.makeKeyAndOrderFront(nil)
        fullScreenWindow = window

        // 激活应用
        NSApp.activate(ignoringOtherApps: true)
    }

    private func hideFullScreen() {
        guard let window = fullScreenWindow else { return }

        // 先清除引用，防止重复关闭
        fullScreenWindow = nil

        // 使用安全关闭方法
        window.safeClose()
    }

    private func updateStatusBarIcon() {
        guard let statusButton = statusItem?.button,
              let viewModel = viewModel else { return }

        if viewModel.settings.isEnabled {
            let remaining = Int(viewModel.remainingTime)
            let minutes = remaining / 60
            let seconds = remaining % 60

            if remaining > 0 {
                statusButton.title = String(format: "%02d:%02d", minutes, seconds)
            } else {
                statusButton.title = ""
            }
        } else {
            statusButton.title = ""
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // 不在关闭最后一个窗口时退出应用
        return false
    }
}
