import SwiftUI
import SwiftData

struct SessionDetailView: View {
    let session: SessionData
    @Environment(DataService.self) private var dataService
    @Environment(LanguageManager.self) private var languageManager

    private var lang: AppLanguage { languageManager.language }

    private var allHands: [HandRecordData] { session.handRecords }
    private var vpipHands: [HandRecordData] { allHands.filter { $0.didVPIP } }
    private var foldHands: [HandRecordData] { allHands.filter { !$0.didVPIP } }
    private var winCount: Int { vpipHands.filter { $0.result == .win }.count }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero BB
                heroSection
                    .padding(.top, 20)
                    .padding(.bottom, 28)

                // Quick stats
                quickStats
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)

                // Detail rows
                detailSection
                    .padding(.bottom, 28)

                // Hand records
                if !allHands.isEmpty {
                    handRecordsSection
                        .padding(.bottom, 20)
                }

                Spacer().frame(height: 80)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color.vtBlack.ignoresSafeArea())
        .navigationTitle({
            if let title = session.title, !title.isEmpty {
                return "\(session.dateLabel(lang)) · \(title)"
            }
            return session.dateLabel(lang)
        }())
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 8) {
            if let bb = session.totalBBResult, bb != 0 {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(String(format: "%+.0f", bb))
                        .font(.system(size: 96, weight: .ultraLight, design: .monospaced))
                        .foregroundColor(.vtText)

                    Text("BB")
                        .font(.system(size: 32, weight: .ultraLight, design: .monospaced))
                        .foregroundColor(.vtDim)
                }
            } else {
                Text("\(session.totalHands)")
                    .font(.system(size: 96, weight: .ultraLight, design: .monospaced))
                    .foregroundColor(.vtText)

                Text(L10n.s(.hands, lang))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.vtDim)
                    .tracking(2)
            }
        }
    }

    // MARK: - Quick Stats

    private var quickStats: some View {
        HStack(spacing: 0) {
            statCell("\(session.totalHands)", L10n.s(.hands, lang))
            statCell("\(session.sessionVPIP)%", "VPIP")

            if !vpipHands.isEmpty {
                let winRate = Int(Double(winCount) / Double(vpipHands.count) * 100)
                statCell("\(winRate)%", L10n.s(.winRate, lang))
            }

            if let bb = session.totalBBResult, session.totalHands >= 10 {
                let bb100 = (bb / Double(session.totalHands)) * 100
                statCell(String(format: "%.1f", bb100), "BB/100")
            }
        }
    }

    private func statCell(_ value: String, _ label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .medium, design: .monospaced))
                .monospacedDigit()
                .foregroundColor(.vtText)

            Text(label)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.vtDim)
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Detail Rows

    private var detailSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.s(.sessionOverview, lang))
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.vtDim)
                .tracking(2)
                .padding(.horizontal, 32)

            VStack(spacing: 0) {
                detailRow(L10n.s(.duration, lang), session.durationFormatted(lang))
                rowDivider
                detailRow(L10n.s(.vpipHands, lang), "\(vpipHands.count)")
                rowDivider
                detailRow(L10n.s(.fold, lang), "\(foldHands.count)")
                rowDivider
                detailRow(L10n.s(.tableSizeLabel, lang), session.tableInfoLabel(lang))
                rowDivider
                detailRow(L10n.s(.date, lang), dateString)

                let gto = getGTOStats()
                if gto.total >= 3 {
                    rowDivider
                    detailRow("GTO", "\(gto.inRange)/\(gto.total) (\(gto.complianceRate)%)")
                }
            }
            .padding(.horizontal, 32)
        }
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.vtText)

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .medium, design: .monospaced))
                .foregroundColor(.vtMuted)
        }
        .padding(.vertical, 14)
    }

    private var rowDivider: some View {
        Rectangle()
            .fill(Color.vtBorder)
            .frame(height: 0.5)
    }

    // MARK: - Hand Records

    private var handRecordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(L10n.s(.entries, lang)) (\(allHands.count))")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.vtDim)
                .tracking(2)
                .padding(.horizontal, 32)

            VStack(spacing: 0) {
                ForEach(Array(allHands.reversed().enumerated()), id: \.element.id) { index, hand in
                    handRow(hand, index: allHands.count - index)

                    if index < allHands.count - 1 {
                        Rectangle()
                            .fill(Color.vtBorder)
                            .frame(height: 0.5)
                            .padding(.leading, 16)
                    }
                }
            }
            .padding(.horizontal, 32)
        }
    }

    private func handRow(_ hand: HandRecordData, index: Int) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    if let ht = hand.handType {
                        Text(ht)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.vtText)
                    } else if hand.didVPIP {
                        Text("VPIP")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.vtText)
                    }

                    if !hand.didVPIP {
                        Text("· FOLD")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.vtMuted)
                    }
                }

                Text("#\(index) · \(hand.didVPIP ? L10n.s(.vpip, lang) : L10n.s(.fold, lang))")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(.vtDim)
            }

            Spacer()

            if hand.didVPIP {
                HStack(spacing: 12) {
                    if let bb = hand.bbResult, bb != 0 {
                        Text(String(format: "%+.0f", bb))
                            .font(.system(size: 15, weight: .medium, design: .monospaced))
                            .monospacedDigit()
                            .foregroundColor(.vtMuted)
                    }

                    Text(hand.result == .win ? "W" : "L")
                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                        .foregroundColor(.vtMuted)
                }
            }
        }
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }

    // MARK: - Helpers

    private var dateString: String {
        let formatter = DateFormatter()
        switch lang {
        case .english: formatter.dateFormat = "M/d HH:mm"
        case .chinese: formatter.dateFormat = "M月d日 HH:mm"
        }
        return formatter.string(from: session.startTime)
    }

    private struct GTOStats {
        let total: Int, inRange: Int, outOfRange: Int
        var complianceRate: Int { total > 0 ? Int(Double(inRange) / Double(total) * 100) : 100 }
    }

    private func getGTOStats() -> GTOStats {
        var inRange = 0, outOfRange = 0
        for hand in vpipHands {
            guard let handType = hand.handType, let position = hand.position, let action = hand.actionType else { continue }
            if GTORange.isInRange(hand: handType, position: position, action: action) { inRange += 1 } else { outOfRange += 1 }
        }
        return GTOStats(total: inRange + outOfRange, inRange: inRange, outOfRange: outOfRange)
    }
}

#Preview {
    NavigationStack {
        SessionDetailView(session: SessionData(startTime: Date().addingTimeInterval(-3600), endTime: Date(), totalHands: 45, vpipHands: 11))
    }
    .environment(DataService(modelContext: PreviewContainer.shared.mainContext))
    .environment(LanguageManager())
    .preferredColorScheme(.dark)
}
