import Foundation

struct EyeCareInterval: Identifiable, Hashable, Codable {
    let id = UUID()
    let minutes: Int
    let displayName: String

    var displayNameWithUnit: String {
        return "\(displayName)分钟"
    }

    enum CodingKeys: String, CodingKey {
        case minutes
        case displayName
    }
}

class EyeCareSettings: ObservableObject {
    @Published var selectedInterval: EyeCareInterval
    @Published var isEnabled: Bool = false
    @Published var fullScreenDuration: TimeInterval = 60 // 默认全屏提示显示60秒

    static let availableIntervals = [
        EyeCareInterval(minutes: 20, displayName: "20"),
        EyeCareInterval(minutes: 30, displayName: "30"),
        EyeCareInterval(minutes: 45, displayName: "45"),
        EyeCareInterval(minutes: 60, displayName: "60"),
    ]

    init() {
        self.selectedInterval = EyeCareSettings.availableIntervals[0]
    }
}
