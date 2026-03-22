import SwiftUI

enum AppearanceMode: Int, CaseIterable {
    case system = 0
    case light = 1
    case dark = 2

    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max"
        case .dark: return "moon"
        }
    }

    func localizedLabel(_ lang: AppLanguage) -> String {
        switch self {
        case .system: return L10n.s(.system, lang)
        case .light: return L10n.s(.light, lang)
        case .dark: return L10n.s(.dark, lang)
        }
    }
}

@Observable
final class AppearanceManager {
    var mode: AppearanceMode {
        didSet {
            UserDefaults.standard.set(mode.rawValue, forKey: "vt_appearance_mode")
        }
    }

    init() {
        let raw = UserDefaults.standard.integer(forKey: "vt_appearance_mode")
        self.mode = AppearanceMode(rawValue: raw) ?? .dark
    }
}
