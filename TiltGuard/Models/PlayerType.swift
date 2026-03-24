import SwiftUI

enum PlayerType: CaseIterable {
    case nit, tight, standard, loose, veryLoose

    var vpipRange: ClosedRange<Int> {
        switch self {
        case .nit: return 0...14
        case .tight: return 15...19
        case .standard: return 20...24
        case .loose: return 25...29
        case .veryLoose: return 30...100
        }
    }

    func displayName(_ lang: AppLanguage) -> String {
        switch lang {
        case .chinese:
            switch self {
            case .nit: return "极紧玩家"
            case .tight: return "紧凶玩家"
            case .standard: return "标准玩家"
            case .loose: return "松凶玩家"
            case .veryLoose: return "极松玩家"
            }
        case .english:
            switch self {
            case .nit: return "Nit"
            case .tight: return "TAG"
            case .standard: return "Standard"
            case .loose: return "LAG"
            case .veryLoose: return "Very Loose"
            }
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
