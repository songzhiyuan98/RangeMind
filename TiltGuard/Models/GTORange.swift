import Foundation

// MARK: - GTO 范围数据

struct GTORange {

    // 各位置的 GTO 开池范围 (Open Raise)
    // 基于 6-max 常规桌标准范围
    static let openRaiseRanges: [PokerPosition: Set<String>] = [
        .utg: Set([
            // 对子
            "AA", "KK", "QQ", "JJ", "TT", "99", "88", "77",
            // 同花
            "AKs", "AQs", "AJs", "ATs", "A5s", "A4s",
            "KQs", "KJs", "KTs",
            "QJs", "QTs",
            "JTs",
            // 杂色
            "AKo", "AQo", "AJo"
        ]),

        .mp: Set([
            // 对子
            "AA", "KK", "QQ", "JJ", "TT", "99", "88", "77", "66",
            // 同花
            "AKs", "AQs", "AJs", "ATs", "A9s", "A5s", "A4s", "A3s",
            "KQs", "KJs", "KTs", "K9s",
            "QJs", "QTs", "Q9s",
            "JTs", "J9s",
            "T9s",
            // 杂色
            "AKo", "AQo", "AJo", "ATo",
            "KQo", "KJo"
        ]),

        .co: Set([
            // 对子
            "AA", "KK", "QQ", "JJ", "TT", "99", "88", "77", "66", "55", "44",
            // 同花
            "AKs", "AQs", "AJs", "ATs", "A9s", "A8s", "A7s", "A6s", "A5s", "A4s", "A3s", "A2s",
            "KQs", "KJs", "KTs", "K9s", "K8s",
            "QJs", "QTs", "Q9s", "Q8s",
            "JTs", "J9s", "J8s",
            "T9s", "T8s",
            "98s", "97s",
            "87s", "86s",
            "76s", "75s",
            "65s",
            // 杂色
            "AKo", "AQo", "AJo", "ATo", "A9o",
            "KQo", "KJo", "KTo",
            "QJo", "QTo",
            "JTo"
        ]),

        .btn: Set([
            // 对子 - 全部
            "AA", "KK", "QQ", "JJ", "TT", "99", "88", "77", "66", "55", "44", "33", "22",
            // 同花 - 大部分
            "AKs", "AQs", "AJs", "ATs", "A9s", "A8s", "A7s", "A6s", "A5s", "A4s", "A3s", "A2s",
            "KQs", "KJs", "KTs", "K9s", "K8s", "K7s", "K6s", "K5s",
            "QJs", "QTs", "Q9s", "Q8s", "Q7s", "Q6s",
            "JTs", "J9s", "J8s", "J7s",
            "T9s", "T8s", "T7s",
            "98s", "97s", "96s",
            "87s", "86s", "85s",
            "76s", "75s", "74s",
            "65s", "64s",
            "54s", "53s",
            "43s",
            // 杂色
            "AKo", "AQo", "AJo", "ATo", "A9o", "A8o", "A7o", "A6o", "A5o", "A4o",
            "KQo", "KJo", "KTo", "K9o", "K8o",
            "QJo", "QTo", "Q9o",
            "JTo", "J9o",
            "T9o",
            "98o"
        ]),

        .sb: Set([
            // 对子 - 全部
            "AA", "KK", "QQ", "JJ", "TT", "99", "88", "77", "66", "55", "44", "33", "22",
            // 同花
            "AKs", "AQs", "AJs", "ATs", "A9s", "A8s", "A7s", "A6s", "A5s", "A4s", "A3s", "A2s",
            "KQs", "KJs", "KTs", "K9s", "K8s", "K7s", "K6s", "K5s", "K4s",
            "QJs", "QTs", "Q9s", "Q8s", "Q7s", "Q6s",
            "JTs", "J9s", "J8s", "J7s",
            "T9s", "T8s", "T7s",
            "98s", "97s", "96s",
            "87s", "86s",
            "76s", "75s",
            "65s", "64s",
            "54s",
            // 杂色
            "AKo", "AQo", "AJo", "ATo", "A9o", "A8o", "A7o",
            "KQo", "KJo", "KTo", "K9o",
            "QJo", "QTo", "Q9o",
            "JTo", "J9o",
            "T9o"
        ]),

        .bb: Set([
            // BB 主要是防守，这里列出可以 3bet 的范围
            "AA", "KK", "QQ", "JJ", "TT", "99",
            "AKs", "AQs", "AJs", "ATs",
            "KQs", "KJs",
            "QJs",
            "AKo", "AQo"
        ])
    ]

    // 各位置的 GTO 跟注范围 (面对加注)
    static let callingRanges: [PokerPosition: Set<String>] = [
        .utg: Set([
            "AA", "KK", "QQ", "JJ", "TT",
            "AKs", "AQs",
            "AKo"
        ]),

        .mp: Set([
            "AA", "KK", "QQ", "JJ", "TT", "99",
            "AKs", "AQs", "AJs",
            "KQs",
            "AKo", "AQo"
        ]),

        .co: Set([
            "AA", "KK", "QQ", "JJ", "TT", "99", "88", "77",
            "AKs", "AQs", "AJs", "ATs",
            "KQs", "KJs", "QJs",
            "AKo", "AQo", "AJo"
        ]),

        .btn: Set([
            "AA", "KK", "QQ", "JJ", "TT", "99", "88", "77", "66",
            "AKs", "AQs", "AJs", "ATs", "A9s", "A5s",
            "KQs", "KJs", "KTs",
            "QJs", "QTs",
            "JTs",
            "AKo", "AQo", "AJo", "ATo",
            "KQo"
        ]),

        .sb: Set([
            "AA", "KK", "QQ", "JJ", "TT", "99", "88",
            "AKs", "AQs", "AJs", "ATs",
            "KQs", "KJs",
            "QJs",
            "AKo", "AQo", "AJo"
        ]),

        .bb: Set([
            // BB 防守范围较宽
            "AA", "KK", "QQ", "JJ", "TT", "99", "88", "77", "66", "55", "44", "33", "22",
            "AKs", "AQs", "AJs", "ATs", "A9s", "A8s", "A7s", "A6s", "A5s", "A4s", "A3s", "A2s",
            "KQs", "KJs", "KTs", "K9s", "K8s",
            "QJs", "QTs", "Q9s",
            "JTs", "J9s",
            "T9s", "T8s",
            "98s", "97s",
            "87s", "86s",
            "76s",
            "65s",
            "AKo", "AQo", "AJo", "ATo", "A9o",
            "KQo", "KJo", "KTo",
            "QJo", "QTo",
            "JTo"
        ])
    ]

    // 明显的弱牌（在任何位置都不应该入池）
    static let obviousWeakHands: Set<String> = Set([
        "72o", "73o", "74o", "75o",
        "82o", "83o", "84o",
        "92o", "93o", "94o",
        "T2o", "T3o", "T4o",
        "J2o", "J3o", "J4o",
        "Q2o", "Q3o", "Q4o", "Q5o",
        "K2o", "K3o", "K4o",
        "72s", "73s", "82s", "83s", "92s", "93s"
    ])

    // MARK: - 范围检查方法

    /// 检查手牌是否在 GTO 范围内
    static func isInRange(hand: String, position: PokerPosition, action: ActionType) -> Bool {
        let range: Set<String>

        switch action {
        case .openRaise:
            range = openRaiseRanges[position] ?? Set()
        case .call:
            range = callingRanges[position] ?? Set()
        case .limp:
            // Limp 通常不在 GTO 范围内（除了 BB check）
            return position == .bb
        case .threeBet:
            // 3bet 范围通常是开池范围的子集
            range = openRaiseRanges[position] ?? Set()
        }

        return range.contains(hand)
    }

    /// 检查是否是明显的弱牌
    static func isObviouslyWeak(hand: String) -> Bool {
        return obviousWeakHands.contains(hand)
    }

    /// 获取该位置的推荐范围
    static func getRecommendedRange(position: PokerPosition) -> Set<String> {
        return openRaiseRanges[position] ?? Set()
    }

    /// 计算手牌与 GTO 的偏离程度
    static func getDeviationLevel(hand: String, position: PokerPosition, action: ActionType) -> DeviationLevel {
        // 如果在范围内
        if isInRange(hand: hand, position: position, action: action) {
            return .none
        }

        // 如果是明显弱牌
        if isObviouslyWeak(hand: hand) {
            return .severe
        }

        // 检查是否在其他位置的范围内
        let inAnyRange = openRaiseRanges.values.contains { $0.contains(hand) }

        if inAnyRange {
            // 在某个位置可以玩，但当前位置不合适
            return .moderate
        } else {
            // 完全不在任何标准范围内
            return .significant
        }
    }

    enum DeviationLevel: Int {
        case none = 0       // 没有偏离
        case slight = 1     // 轻微偏离（边缘手牌）
        case moderate = 2   // 中度偏离（位置不对）
        case significant = 3 // 显著偏离
        case severe = 4     // 严重偏离（垃圾牌）

        var description: String {
            switch self {
            case .none: return "标准范围"
            case .slight: return "边缘手牌"
            case .moderate: return "位置偏松"
            case .significant: return "范围偏离"
            case .severe: return "严重偏离"
            }
        }

        var shouldWarn: Bool {
            return self.rawValue >= DeviationLevel.moderate.rawValue
        }
    }
}

// MARK: - GTO 分析结果

struct GTOAnalysisResult {
    let hand: String
    let position: PokerPosition
    let action: ActionType
    let isInRange: Bool
    let deviationLevel: GTORange.DeviationLevel
    let recommendation: String

    var warningMessage: String? {
        guard deviationLevel.shouldWarn else { return nil }

        switch deviationLevel {
        case .moderate:
            return "不建议 \(hand) 在 \(position.displayName) \(action.displayName)"
        case .significant:
            return "\(hand) 在 \(position.displayName) \(action.displayName) 不在标准范围"
        case .severe:
            return "\(hand) 是弱牌，不建议入池"
        default:
            return nil
        }
    }
}
