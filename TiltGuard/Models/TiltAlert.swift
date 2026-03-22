import SwiftUI

struct TiltAlert: Equatable {
    let type: AlertType
    let message: String

    enum AlertType {
        case warning
        case danger
    }

    var icon: String {
        switch type {
        case .warning: return "⚠️"
        case .danger: return "🚨"
        }
    }

    var color: Color {
        switch type {
        case .warning: return .warning
        case .danger: return .danger
        }
    }

    // 预设警告
    static let vpipHigh = TiltAlert(
        type: .warning,
        message: "入池率偏高 · 比平时松了"
    )

    static let possibleTilt = TiltAlert(
        type: .danger,
        message: "可能在上头 · 连续未赢，建议休息"
    )

    static let rangeExpanding = TiltAlert(
        type: .warning,
        message: "范围扩大 · 你在玩太多边缘牌"
    )
}
