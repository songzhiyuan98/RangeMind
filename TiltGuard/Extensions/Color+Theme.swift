import SwiftUI
import UIKit

extension Color {
    // MARK: - Background
    static let vtBlack = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(r: 0x08, g: 0x08, b: 0x0A)
            : UIColor(r: 0xFA, g: 0xFA, b: 0xFA)
    })

    static let vtSurface = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(r: 0x13, g: 0x13, b: 0x16)
            : UIColor(r: 0xFF, g: 0xFF, b: 0xFF)
    })

    static let vtElevated = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(r: 0x1A, g: 0x1A, b: 0x1E)
            : UIColor(r: 0xF0, g: 0xF0, b: 0xF2)
    })

    // MARK: - Accent
    static let vtAccent = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(r: 0xA7, g: 0x8B, b: 0xFA)   // soft violet
            : UIColor(r: 0x8B, g: 0x5C, b: 0xF6)   // deeper for light bg
    })

    static let vtAccentMuted = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(r: 0xA7, g: 0x8B, b: 0xFA, a: 0.15)
            : UIColor(r: 0x8B, g: 0x5C, b: 0xF6, a: 0.10)
    })

    // MARK: - Text
    static let vtText = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(r: 0xE4, g: 0xE4, b: 0xE7)
            : UIColor(r: 0x1A, g: 0x1A, b: 0x1E)
    })

    static let vtMuted = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(r: 0x71, g: 0x71, b: 0x7A)
            : UIColor(r: 0x6B, g: 0x72, b: 0x80)
    })

    static let vtDim = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(r: 0x3F, g: 0x3F, b: 0x46)
            : UIColor(r: 0x9C, g: 0xA3, b: 0xAF)
    })

    // MARK: - Border
    static let vtBorder = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.06)
            : UIColor.black.withAlphaComponent(0.08)
    })

    // MARK: - Semantic
    static let vtGreen = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(r: 0x4A, g: 0xDE, b: 0x80)
            : UIColor(r: 0x16, g: 0xA3, b: 0x4A)
    })

    static let vtRed = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(r: 0xF8, g: 0x71, b: 0x71)
            : UIColor(r: 0xDC, g: 0x26, b: 0x26)
    })

    static let vtAmber = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(r: 0xFB, g: 0xBF, b: 0x24)
            : UIColor(r: 0xD9, g: 0x77, b: 0x06)
    })

    static let vtTeal = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(r: 0x2D, g: 0xD4, b: 0xBF)
            : UIColor(r: 0x0D, g: 0x94, b: 0x88)
    })

    // MARK: - Liquid Glass
    static let lgGlow = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(r: 0xA7, g: 0x8B, b: 0xFA, a: 0.6)
            : UIColor(r: 0x8B, g: 0x5C, b: 0xF6, a: 0.4)
    })

    static let lgSurface = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.08)
            : UIColor.white.withAlphaComponent(0.6)
    })

    static let lgBorder = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.15)
            : UIColor.white.withAlphaComponent(0.4)
    })

    static let lgHighlight = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.25)
            : UIColor.white.withAlphaComponent(0.7)
    })

    // MARK: - Legacy aliases
    static let darkBg = vtBlack
    static let cardBg = vtSurface
    static let surfaceBg = vtElevated
    static let elevatedBg = vtElevated
    static let textPrimary = vtText
    static let textSecondary = vtMuted
    static let textTertiary = vtDim
    static let surfaceBorder = vtBorder
    static let glassBackground = vtSurface
    static let pokerGreen = vtAccent
    static let pokerGreenLight = vtAccent
    static let warning = vtAmber
    static let danger = vtRed

    // MARK: - Hex Init
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - UIColor convenience

extension UIColor {
    convenience init(r: UInt8, g: UInt8, b: UInt8, a: Double = 1.0) {
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: a
        )
    }
}
