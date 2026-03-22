import Foundation

struct HandRecord: Identifiable {
    let id: UUID
    let sessionId: UUID
    let timestamp: Date
    let didVPIP: Bool

    // VPIP 相关（仅当 didVPIP = true）
    var card1Rank: String?
    var card2Rank: String?
    var isSuited: Bool?
    var result: HandResult?

    // Pro 预留字段
    var position: String?
    var bbResult: Double?
    var actionType: String?

    var handType: String? {
        guard let c1 = card1Rank, let c2 = card2Rank else { return nil }

        let ranks = ["A", "K", "Q", "J", "T", "9", "8", "7", "6", "5", "4", "3", "2"]
        let sorted = [c1, c2].sorted { ranks.firstIndex(of: $0)! < ranks.firstIndex(of: $1)! }

        // 口袋对
        if c1 == c2 {
            return "\(c1)\(c2)"
        }

        // 非口袋对
        let suffix = (isSuited ?? false) ? "s" : "o"
        return "\(sorted[0])\(sorted[1])\(suffix)"
    }

    var isPocketPair: Bool {
        card1Rank == card2Rank && card1Rank != nil
    }

    init(
        id: UUID = UUID(),
        sessionId: UUID,
        timestamp: Date = Date(),
        didVPIP: Bool,
        card1Rank: String? = nil,
        card2Rank: String? = nil,
        isSuited: Bool? = nil,
        result: HandResult? = nil
    ) {
        self.id = id
        self.sessionId = sessionId
        self.timestamp = timestamp
        self.didVPIP = didVPIP
        self.card1Rank = card1Rank
        self.card2Rank = card2Rank
        self.isSuited = isSuited
        self.result = result
    }
}

enum HandResult: String {
    case win = "WIN"
    case notWin = "NOT_WIN"
}
