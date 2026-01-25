import Cocoa
import SwiftUI

class FullScreenWindow: NSPanel {
    private var hostingController: NSHostingController<FullScreenReminderView>?
    private var cleanupTimer: Timer?

    init(contentView: FullScreenReminderView) {
        super.init(
            contentRect: NSScreen.main?.frame ?? .zero,
            styleMask: [.borderless, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        self.isFloatingPanel = true
        self.level = .screenSaver
        self.backgroundColor = .clear
        self.isOpaque = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAllowsTiling]
        self.hidesOnDeactivate = false

        if let screen = NSScreen.main {
            self.setFrame(screen.frame, display: false)
        }

        let hostingController = NSHostingController(rootView: contentView)
        self.hostingController = hostingController
        self.contentViewController = hostingController
    }

    override func close() {
        // 停止所有定时器
        cleanupTimer?.invalidate()
        cleanupTimer = nil

        // 清除 contentViewController
        let contentView = self.contentViewController
        self.contentViewController = nil

        // 延迟清理，确保当前事件循环完成
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
            self?.hostingController = nil
        }

        super.close()
    }

    func safeClose() {
        DispatchQueue.main.async { [weak self] in
            self?.close()
        }
    }
}
