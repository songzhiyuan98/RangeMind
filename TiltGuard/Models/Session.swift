import Foundation

struct Session: Identifiable {
    let id: UUID
    let startTime: Date
    var endTime: Date?
    var totalHands: Int
    var vpipHands: Int

    var sessionVPIP: Int {
        guard totalHands > 0 else { return 0 }
        return Int(Double(vpipHands) / Double(totalHands) * 100)
    }

    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }

    var durationFormatted: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60

        if hours > 0 {
            return "\(hours)小时\(minutes)分"
        } else {
            return "\(minutes)分钟"
        }
    }

    var dateLabel: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(startTime) {
            return "今天"
        } else if calendar.isDateInYesterday(startTime) {
            return "昨天"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "M月d日"
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
}
