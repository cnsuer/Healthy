import Cocoa
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - Properties
    private var viewModel: EyeCareViewModel?
    private var statusBarManager: StatusBarManager?
    private var popover: NSPopover?
    private var fullScreenWindow: FullScreenWindow?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Application Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 创建 ViewModel
        let viewModel = EyeCareViewModel()
        self.viewModel = viewModel

        // 设置状态栏管理器
        let statusBarManager = StatusBarManager()
        self.statusBarManager = statusBarManager
        statusBarManager.setup { [weak self] in
            self?.statusBarButtonClicked()
        }

        // 创建弹出菜单
        setupPopover()

        // 设置 Combine 订阅
        setupSubscriptions()
    }

    // MARK: - Setup Methods

    private func setupPopover() {
        guard let viewModel = viewModel else { return }

        popover = NSPopover()
        popover?.contentSize = NSSize(width: 300, height: 500)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(
            rootView: EyeCareMenuView(viewModel: viewModel)
        )
    }

    private func setupSubscriptions() {
        guard let viewModel = viewModel else { return }

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

    // MARK: - UI Actions

    @objc private func statusBarButtonClicked() {
        guard let statusBarManager = statusBarManager,
              let statusButton = statusBarManager.statusItem?.button else {
            return
        }

        if let popover = popover, popover.isShown {
            popover.performClose(nil)
        } else {
            popover?.show(relativeTo: statusButton.bounds, of: statusButton, preferredEdge: .minY)
        }
    }

    // MARK: - Full Screen Management

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

    // MARK: - Status Bar Updates

    private func updateStatusBarIcon() {
        guard let viewModel = viewModel,
              let statusBarManager = statusBarManager else {
            return
        }

        if viewModel.settings.isEnabled {
            let remaining = Int(viewModel.remainingTime)
            let minutes = remaining / 60
            let seconds = remaining % 60

            if remaining > 0 {
                statusBarManager.updateIcon(minutes: minutes, seconds: seconds)
            } else {
                statusBarManager.clearIcon()
            }
        } else {
            statusBarManager.clearIcon()
        }
    }

    // MARK: - Application Termination

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // 不在关闭最后一个窗口时退出应用
        return false
    }
}
