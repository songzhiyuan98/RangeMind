import Foundation
import SwiftData

@Model
final class PlayerData {
    var id: UUID
    var createdAt: Date
    var lifetimeHands: Int
    var lifetimeVPIPHands: Int

    var lifetimeVPIP: Int {
        guard lifetimeHands > 0 else { return 0 }
        return Int(Double(lifetimeVPIPHands) / Double(lifetimeHands) * 100)
    }

    var playerType: PlayerType {
        PlayerType.from(vpip: lifetimeVPIP)
    }

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        lifetimeHands: Int = 0,
        lifetimeVPIPHands: Int = 0
    ) {
        self.id = id
        self.createdAt = createdAt
        self.lifetimeHands = lifetimeHands
        self.lifetimeVPIPHands = lifetimeVPIPHands
    }

    func addHand(didVPIP: Bool) {
        lifetimeHands += 1
        if didVPIP {
            lifetimeVPIPHands += 1
        }
    }
}
