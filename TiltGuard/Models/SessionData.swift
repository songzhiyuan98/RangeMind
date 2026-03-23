import Foundation
import SwiftData

@Model
final class SessionData {
    var id: UUID
    var ownerUserID: String
    var startTime: Date
    var endTime: Date?
    var totalHands: Int
    var vpipHands: Int

    // Pro
    var totalBBResult: Double?

    // Guest mode
    var isGuestSession: Bool

    // Session title (location/casino name)
    var title: String?

    // Game configuration (3-dimension)
    var gameModeRaw: String?
    var tableSizeRaw: String?
    var tableStyleRaw: String?

    @Relationship(deleteRule: .cascade, inverse: \HandRecordData.session)
    var handRecords: [HandRecordData] = []

    var gameMode: GameMode {
        get { GameMode(rawValue: gameModeRaw ?? "") ?? .cash }
        set { gameModeRaw = newValue.rawValue }
    }

    var tableSize: TableSize {
        get { TableSize(rawValue: tableSizeRaw ?? "") ?? .sixMax }
        set { tableSizeRaw = newValue.rawValue }
    }

    var tableStyle: PokerTableStyle {
        get { PokerTableStyle(rawValue: tableStyleRaw ?? "") ?? .standard }
        set { tableStyleRaw = newValue.rawValue }
    }

    var sessionVPIP: Int {
        guard totalHands > 0 else { return 0 }
        return Int(Double(vpipHands) / Double(totalHands) * 100)
    }

    var isActive: Bool {
        endTime == nil
    }

    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }

    // Convenience computed properties (default to English for backward compat)
    var durationFormatted: String { durationFormatted(.english) }
    var dateLabel: String { dateLabel(.english) }

    func durationFormatted(_ lang: AppLanguage) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let h = L10n.s(.hourShort, lang)
        let m = L10n.s(.minuteShort, lang)
        if hours > 0 {
            return "\(hours)\(h) \(minutes)\(m)"
        } else {
            return "\(minutes)\(m)"
        }
    }

    func dateLabel(_ lang: AppLanguage) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(startTime) {
            return L10n.s(.today, lang)
        } else if calendar.isDateInYesterday(startTime) {
            return L10n.s(.yesterday, lang)
        } else {
            let formatter = DateFormatter()
            switch lang {
            case .english:
                formatter.dateFormat = "MMM d"
            case .chinese:
                formatter.dateFormat = "M月d日"
            }
            return formatter.string(from: startTime)
        }
    }

    /// Short label for table config, e.g. "Cash · 6-MAX" or "Tournament · 9-MAX · Loose"
    func tableInfoLabel(_ lang: AppLanguage) -> String {
        var parts: [String] = []
        parts.append(L10n.gameModeName(gameMode, lang))
        parts.append(L10n.tableSizeName(tableSize, lang))
        if tableStyle != .standard {
            parts.append(L10n.tableStyleName(tableStyle, lang))
        }
        return parts.joined(separator: " · ")
    }

    init(
        id: UUID = UUID(),
        ownerUserID: String = "",
        startTime: Date = Date(),
        endTime: Date? = nil,
        totalHands: Int = 0,
        vpipHands: Int = 0,
        isGuestSession: Bool = false,
        title: String? = nil,
        gameMode: GameMode = .cash,
        tableSize: TableSize = .sixMax,
        tableStyle: PokerTableStyle = .standard
    ) {
        self.id = id
        self.ownerUserID = ownerUserID
        self.startTime = startTime
        self.endTime = endTime
        self.totalHands = totalHands
        self.vpipHands = vpipHands
        self.isGuestSession = isGuestSession
        self.title = title
        self.gameModeRaw = gameMode.rawValue
        self.tableSizeRaw = tableSize.rawValue
        self.tableStyleRaw = tableStyle.rawValue
    }

    func toSession() -> Session {
        Session(
            id: id,
            startTime: startTime,
            endTime: endTime,
            totalHands: totalHands,
            vpipHands: vpipHands
        )
    }
}
