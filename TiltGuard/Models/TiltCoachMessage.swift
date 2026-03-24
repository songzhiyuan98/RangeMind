import Foundation

// MARK: - Game & Table Configuration (3-Dimension Model)

enum GameMode: String, CaseIterable, Identifiable, Codable {
    case cash
    case tournament

    var id: String { rawValue }
}

enum TableSize: String, CaseIterable, Identifiable, Codable {
    case headsUp = "HU"
    case sixMax = "6max"
    case nineMax = "9max"
    case fullRing = "FR"

    var id: String { rawValue }
}

enum PokerTableStyle: String, CaseIterable, Identifiable, Codable {
    case standard
    case loose
    case friendly

    var id: String { rawValue }
}

// MARK: - Tilt Categories

enum TiltCategory: String {
    case lossTilt      // Loss Chase
    case techTilt      // Technical Tilt
    case bigPot        // Big Pot
}

// MARK: - Big Pot Tier

enum PotTier {
    case large    // 100–149BB
    case huge     // 150–249BB
    case massive  // ≥250BB

    static func from(bb: Double) -> PotTier? {
        let abs = Swift.abs(bb)
        if abs >= 250 { return .massive }
        if abs >= 150 { return .huge }
        if abs >= 100 { return .large }
        return nil
    }
}

// MARK: - Coach Message

struct TiltCoachMessage {
    enum MessageType {
        case warning
        case danger
        case watch
        case recovering
    }

    let type: MessageType
    let category: TiltCategory
    let headline: String
    let detail: String
}
