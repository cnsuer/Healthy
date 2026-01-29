import Foundation

struct TimeFormatter {
    /// 格式化时间间隔为 MM:SS 格式
    /// - Parameter time: 时间间隔（秒）
    /// - Returns: 格式化后的字符串，例如 "05:30"
    static func format(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
