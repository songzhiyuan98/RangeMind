import Foundation

/// Hand percentile ranking for 169 starting hands.
/// Lower percentile = stronger hand (AA ≈ 0.45%, 72o = 100%).
/// Cumulative percentile accounts for combo counts (pair=6, suited=4, offsuit=12).
struct HandPercentile {

    enum Classification {
        case baseline    // Within player's normal range
        case edge        // Between baseline and tolerance (+1 risk)
        case deviation   // Beyond tolerance (+2 risk)
    }

    /// Classify a hand relative to baseline and tolerance percentages
    static func classify(_ handType: String, baseline: Double, tolerance: Double) -> Classification {
        let pct = percentile(for: handType)
        if pct <= baseline { return .baseline }
        if pct <= tolerance { return .edge }
        return .deviation
    }

    /// Get the cumulative percentile for a hand type (0-100)
    static func percentile(for handType: String) -> Double {
        return table[handType] ?? 100.0
    }

    // MARK: - Precomputed Table

    /// 169 hands ordered strongest to weakest, with combo-weighted cumulative percentile
    private static let table: [String: Double] = {
        // (handType, combos) — ordered by preflop equity (strongest first)
        let ranking: [(String, Int)] = [
            // Tier 1: Premium
            ("AA", 6), ("KK", 6), ("QQ", 6), ("AKs", 4), ("JJ", 6),
            // Tier 2: Strong
            ("AQs", 4), ("KQs", 4), ("AJs", 4), ("TT", 6), ("AKo", 12),
            ("KJs", 4), ("ATs", 4), ("QJs", 4), ("KTs", 4), ("QTs", 4), ("JTs", 4),
            // Tier 3: Playable
            ("99", 6), ("AQo", 12), ("A9s", 4), ("KQo", 12), ("K9s", 4),
            ("T9s", 4), ("A8s", 4), ("J9s", 4), ("Q9s", 4),
            // Tier 4: Positional
            ("AJo", 12), ("88", 6), ("A5s", 4), ("A7s", 4), ("A4s", 4),
            ("A6s", 4), ("A3s", 4), ("KJo", 12), ("K8s", 4), ("T8s", 4),
            ("A2s", 4), ("QJo", 12), ("98s", 4), ("K7s", 4),
            // Tier 5: Speculative
            ("77", 6), ("ATo", 12), ("Q8s", 4), ("J8s", 4), ("K6s", 4),
            ("87s", 4), ("KTo", 12), ("QTo", 12), ("JTo", 12), ("97s", 4), ("76s", 4),
            // Tier 6: Marginal
            ("A9o", 12), ("K5s", 4), ("66", 6), ("T7s", 4), ("86s", 4),
            ("K4s", 4), ("65s", 4), ("J7s", 4), ("A8o", 12), ("Q7s", 4),
            ("K3s", 4), ("55", 6), ("96s", 4),
            // Tier 7: Weak-Speculative
            ("A5o", 12), ("75s", 4), ("A7o", 12), ("K2s", 4), ("Q6s", 4),
            ("54s", 4), ("A4o", 12), ("T6s", 4), ("85s", 4), ("A6o", 12), ("Q5s", 4),
            // Tier 8: Weak
            ("44", 6), ("A3o", 12), ("J6s", 4), ("64s", 4), ("Q4s", 4),
            ("98o", 12), ("A2o", 12), ("33", 6), ("J5s", 4), ("T8o", 12),
            ("Q3s", 4), ("87o", 12), ("Q8o", 12),
            // Tier 9: Very Weak
            ("K9o", 12), ("53s", 4), ("84s", 4), ("J4s", 4), ("Q2s", 4),
            ("74s", 4), ("T7o", 12), ("J8o", 12), ("22", 6), ("K8o", 12),
            ("76o", 12), ("97o", 12),
            // Tier 10: Garbage - Suited
            ("J3s", 4), ("J9o", 12), ("T9o", 12), ("95s", 4), ("63s", 4),
            ("J2s", 4), ("K7o", 12), ("86o", 12), ("T6o", 12), ("Q9o", 12),
            ("43s", 4), ("65o", 12), ("93s", 4), ("K6o", 12), ("T5s", 4),
            ("73s", 4), ("52s", 4), ("T4s", 4),
            // Tier 11: Garbage - Offsuit
            ("54o", 12), ("K5o", 12), ("82s", 4), ("Q7o", 12), ("T3s", 4),
            ("42s", 4), ("K4o", 12), ("75o", 12), ("92s", 4), ("64o", 12),
            ("T2s", 4), ("K3o", 12), ("Q6o", 12), ("85o", 12), ("83s", 4),
            ("53o", 12), ("K2o", 12), ("32s", 4),
            // Tier 12: Trash
            ("Q5o", 12), ("96o", 12), ("62s", 4), ("43o", 12), ("J7o", 12),
            ("Q4o", 12), ("94o", 12), ("72s", 4), ("J6o", 12), ("Q3o", 12),
            ("52o", 12), ("T5o", 12), ("74o", 12), ("84o", 12), ("J5o", 12),
            ("Q2o", 12), ("63o", 12), ("42o", 12), ("93o", 12), ("J4o", 12),
            ("73o", 12), ("T4o", 12), ("82o", 12), ("32o", 12), ("J3o", 12),
            ("92o", 12), ("62o", 12), ("T3o", 12), ("J2o", 12), ("72o", 12),
            ("83o", 12), ("T2o", 12)
        ]

        var result: [String: Double] = [:]
        var cumCombos = 0
        let totalCombos = 1326

        for (hand, combos) in ranking {
            cumCombos += combos
            // Percentile = cumulative combos / total combos * 100
            result[hand] = Double(cumCombos) / Double(totalCombos) * 100.0
        }

        return result
    }()
}
