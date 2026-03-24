import SwiftUI

enum GlowStatus {
    case normal
    case warning
    case danger
    case recovering

    var color: Color {
        switch self {
        case .normal: return .pokerGreen
        case .warning: return .warning
        case .danger: return .danger
        case .recovering: return .vtTeal
        }
    }

    var animationDuration: Double {
        switch self {
        case .normal: return 3.0
        case .warning: return 1.5
        case .danger: return 0.5
        case .recovering: return 2.0
        }
    }

    var opacityRange: (min: Double, max: Double) {
        switch self {
        case .normal: return (0.2, 0.4)
        case .warning: return (0.3, 0.6)
        case .danger: return (0.4, 0.7)
        case .recovering: return (0.2, 0.5)
        }
    }
}
