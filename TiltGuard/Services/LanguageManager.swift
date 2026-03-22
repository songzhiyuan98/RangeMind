import SwiftUI

enum AppLanguage: Int, CaseIterable {
    case english = 0
    case chinese = 1

    var label: String {
        switch self {
        case .english: return "English"
        case .chinese: return "中文"
        }
    }

    var shortLabel: String {
        switch self {
        case .english: return "EN"
        case .chinese: return "中文"
        }
    }

    var icon: String {
        switch self {
        case .english: return "e.circle"
        case .chinese: return "character.bubble"
        }
    }
}

@Observable
final class LanguageManager {
    var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: "vt_language")
        }
    }

    init() {
        let raw = UserDefaults.standard.integer(forKey: "vt_language")
        self.language = AppLanguage(rawValue: raw) ?? .english
    }
}
