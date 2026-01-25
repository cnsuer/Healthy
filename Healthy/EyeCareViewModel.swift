import Foundation
import SwiftUI
import Combine

class EyeCareViewModel: ObservableObject {
    @Published var settings: EyeCareSettings
    @Published var remainingTime: TimeInterval = 0
    @Published var showFullScreen: Bool = false
    @Published var currentInterval: EyeCareInterval?
    @Published var fullScreenRemainingTime: TimeInterval = 60

    private var timer: Timer?
    private var fullScreenTimer: Timer?
    private let userDefaults = UserDefaults.standard
    private let selectedIntervalKey = "selectedInterval"
    private let isEnabledKey = "isEnabled"

    init(settings: EyeCareSettings = EyeCareSettings()) {
        self.settings = settings
        loadSettings()
        updateRemainingTime()
    }

    // MARK: - Public Methods

    func toggleEnabled() {
        settings.isEnabled.toggle()
        saveSettings()

        if settings.isEnabled {
            startTimer()
        } else {
            stopTimer()
        }
        updateRemainingTime()
    }

    func selectInterval(_ interval: EyeCareInterval) {
        settings.selectedInterval = interval
        saveSettings()
        updateRemainingTime()

        // 如果当前已启用，重启计时器
        if settings.isEnabled {
            stopTimer()
            startTimer()
        }
    }

    func testFullScreen() {
        showFullScreenAlert()
    }

    func dismissFullScreen() {
        // 停止全屏计时器
        stopFullScreenTimer()

        // 关闭全屏后重新开始计时
        if settings.isEnabled {
            stopTimer()
            startTimer()
        }

        // 关闭全屏
        showFullScreen = false
    }

    // MARK: - Private Methods

    private func startTimer() {
        guard settings.isEnabled else { return }

        let interval = TimeInterval(settings.selectedInterval.minutes * 60)
        remainingTime = interval
        currentInterval = settings.selectedInterval

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.remainingTime -= 1

            if self.remainingTime <= 0 {
                self.stopTimer()
                self.showFullScreenAlert()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func showFullScreenAlert() {
        fullScreenRemainingTime = settings.fullScreenDuration
        showFullScreen = true
        startFullScreenTimer()
    }

    private func startFullScreenTimer() {
        // 全屏提示自动退出计时器
        fullScreenTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { [weak self] _ in
            guard let self = self else { return }
            if self.fullScreenRemainingTime > 0 {
                self.fullScreenRemainingTime -= 1
            } else {
                self.dismissFullScreen()
            }
        }
    }

    private func stopFullScreenTimer() {
        fullScreenTimer?.invalidate()
        fullScreenTimer = nil
    }

    private func updateRemainingTime() {
        if settings.isEnabled && timer != nil {
            // 计时器正在运行
        } else if settings.isEnabled {
            // 已启用但计时器未启动
            remainingTime = TimeInterval(settings.selectedInterval.minutes * 60)
        } else {
            remainingTime = 0
        }
    }

    // MARK: - Settings Persistence

    private func saveSettings() {
        if let intervalData = try? JSONEncoder().encode(settings.selectedInterval) {
            userDefaults.set(intervalData, forKey: selectedIntervalKey)
        }
        userDefaults.set(settings.isEnabled, forKey: isEnabledKey)
    }

    private func loadSettings() {
        if let intervalData = userDefaults.data(forKey: selectedIntervalKey),
           let decodedInterval = try? JSONDecoder().decode(EyeCareInterval.self, from: intervalData) {
            settings.selectedInterval = decodedInterval
        }
        settings.isEnabled = userDefaults.bool(forKey: isEnabledKey)

        // 如果保存的状态是启用的，自动启动计时器
        if settings.isEnabled {
            startTimer()
        }
    }

    deinit {
        stopTimer()
        stopFullScreenTimer()
    }

    // MARK: - Formatting

    func formattedRemainingTime() -> String {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func statusMessage() -> String {
        if !settings.isEnabled {
            return "护眼提醒已关闭"
        } else if remainingTime > 0 {
            return "距离休息还有: \(formattedRemainingTime())"
        } else {
            return "准备启动..."
        }
    }
}
