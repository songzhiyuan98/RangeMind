import SwiftUI

enum PlayerType: String, CaseIterable {
    case nit = "极紧玩家"
    case tight = "紧凶玩家"
    case standard = "标准玩家"
    case loose = "松凶玩家"
    case veryLoose = "极松玩家"

    var vpipRange: ClosedRange<Int> {
        switch self {
        case .nit: return 0...14
        case .tight: return 15...19
        case .standard: return 20...24
        case .loose: return 25...29
        case .veryLoose: return 30...100
        }
    }

    var description: String {
        switch self {
        case .nit: return "0-14% 入池率"
        case .tight: return "15-19% 入池率"
        case .standard: return "20-24% 入池率"
        case .loose: return "25-29% 入池率"
        case .veryLoose: return "30%+ 入池率"
        }
    }

    var color: Color {
        switch self {
        case .nit: return .blue
        case .tight: return .cyan
        case .standard: return .pokerGreen
        case .loose: return .orange
        case .veryLoose: return .red
        }
    }

    static func from(vpip: Int) -> PlayerType {
        for type in PlayerType.allCases {
            if type.vpipRange.contains(vpip) {
                return type
            }
        }
        return .standard
    }
}
