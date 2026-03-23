import Foundation
import SwiftData

// MARK: - Position Enum

enum PokerPosition: String, CaseIterable, Identifiable {
    case utg = "UTG"
    case mp = "MP"
    case co = "CO"
    case btn = "BTN"
    case sb = "SB"
    case bb = "BB"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .utg: return "枪口"
        case .mp: return "中位"
        case .co: return "切位"
        case .btn: return "庄位"
        case .sb: return "小盲"
        case .bb: return "大盲"
        }
    }
}

// MARK: - Action Type Enum (第一手行动)

enum ActionType: String, CaseIterable, Identifiable {
    case openRaise = "Open"
    case limp = "Limp"
    case call = "Call"
    case threeBet = "3Bet"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .openRaise: return "开池加注"
        case .limp: return "溜入"
        case .call: return "跟注"
        case .threeBet: return "3Bet"
        }
    }

    var shortName: String {
        switch self {
        case .openRaise: return "Open"
        case .limp: return "Limp"
        case .call: return "Call"
        case .threeBet: return "3Bet"
        }
    }
}

// MARK: - Emotion Signal

enum EmotionSignal: String, CaseIterable, Identifiable {
    case badBeat    // AA vs 72o river 2
    case cooler     // KK vs AA, set over set
    case tilt       // Player self-reports tilting

    var id: String { rawValue }
}

@Model
final class HandRecordData {
    var id: UUID
    var timestamp: Date
    var didVPIP: Bool

    // VPIP 相关
    var card1Rank: String?
    var card2Rank: String?
    var isSuited: Bool?
    var resultRaw: String?

    // GTO deviation tracking
    var isGTODeviation: Bool?

    // Emotion signal (optional self-report)
    var emotionSignalRaw: String?

    // Pro 功能字段
    var bbResult: Double?
    var positionRaw: String?
    var actionTypeRaw: String?

    // 关联
    var session: SessionData?

    var result: HandResult? {
        get {
            guard let raw = resultRaw else { return nil }
            return HandResult(rawValue: raw)
        }
        set {
            resultRaw = newValue?.rawValue
        }
    }

    var position: PokerPosition? {
        get {
            guard let raw = positionRaw else { return nil }
            return PokerPosition(rawValue: raw)
        }
        set {
            positionRaw = newValue?.rawValue
        }
    }

    var actionType: ActionType? {
        get {
            guard let raw = actionTypeRaw else { return nil }
            return ActionType(rawValue: raw)
        }
        set {
            actionTypeRaw = newValue?.rawValue
        }
    }

    var emotionSignal: EmotionSignal? {
        get {
            guard let raw = emotionSignalRaw else { return nil }
            return EmotionSignal(rawValue: raw)
        }
        set {
            emotionSignalRaw = newValue?.rawValue
        }
    }

    var handType: String? {
        guard let c1 = card1Rank, let c2 = card2Rank else { return nil }

        let ranks = ["A", "K", "Q", "J", "T", "9", "8", "7", "6", "5", "4", "3", "2"]
        let sorted = [c1, c2].sorted { ranks.firstIndex(of: $0)! < ranks.firstIndex(of: $1)! }

        if c1 == c2 {
            return "\(c1)\(c2)"
        }

        let suffix = (isSuited ?? false) ? "s" : "o"
        return "\(sorted[0])\(sorted[1])\(suffix)"
    }

    var isPocketPair: Bool {
        card1Rank == card2Rank && card1Rank != nil
    }

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        didVPIP: Bool,
        card1Rank: String? = nil,
        card2Rank: String? = nil,
        isSuited: Bool? = nil,
        result: HandResult? = nil,
        isGTODeviation: Bool? = nil,
        emotionSignal: EmotionSignal? = nil,
        bbResult: Double? = nil,
        position: PokerPosition? = nil,
        actionType: ActionType? = nil,
        session: SessionData? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.didVPIP = didVPIP
        self.card1Rank = card1Rank
        self.card2Rank = card2Rank
        self.isSuited = isSuited
        self.resultRaw = result?.rawValue
        self.isGTODeviation = isGTODeviation
        self.emotionSignalRaw = emotionSignal?.rawValue
        self.bbResult = bbResult
        self.positionRaw = position?.rawValue
        self.actionTypeRaw = actionType?.rawValue
        self.session = session
    }

    // 转换为视图使用的 HandRecord 结构体
    func toHandRecord() -> HandRecord {
        HandRecord(
            id: id,
            sessionId: session?.id ?? UUID(),
            timestamp: timestamp,
            didVPIP: didVPIP,
            card1Rank: card1Rank,
            card2Rank: card2Rank,
            isSuited: isSuited,
            result: result
        )
    }
}
