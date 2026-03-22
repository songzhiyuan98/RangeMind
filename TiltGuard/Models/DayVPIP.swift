import SwiftUI

struct DayVPIP: Identifiable {
    let id = UUID()
    let label: String
    let vpip: Int

    var isHigh: Bool {
        vpip > 25
    }

    var barColor: Color {
        isHigh ? .warning : .pokerGreen
    }
}

struct HandStat: Identifiable {
    let id = UUID()
    let handType: String
    let playCount: Int
    let winCount: Int

    var winRate: Int {
        guard playCount > 0 else { return 0 }
        return Int(Double(winCount) / Double(playCount) * 100)
    }
}
