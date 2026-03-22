import Foundation
import SwiftData

@Model
final class SessionData {
    var id: UUID
    var startTime: Date
    var endTime: Date?
    var totalHands: Int
    var vpipHands: Int

    // Pro 功能字段
    var totalBBResult: Double?

    @Relationship(deleteRule: .cascade, inverse: \HandRecordData.session)
    var handRecords: [HandRecordData] = []

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

    init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        endTime: Date? = nil,
        totalHands: Int = 0,
        vpipHands: Int = 0
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.totalHands = totalHands
        self.vpipHands = vpipHands
    }

    // 转换为视图模型使用的 Session 结构体
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
