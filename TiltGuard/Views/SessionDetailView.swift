import SwiftUI
import SwiftData

struct SessionDetailView: View {
    let session: SessionData
    @Environment(DataService.self) private var dataService
    @Environment(LanguageManager.self) private var languageManager

    private var lang: AppLanguage { languageManager.language }

    private var vpipHands: [HandRecordData] {
        session.handRecords.filter { $0.didVPIP }
    }

    private var winCount: Int {
        vpipHands.filter { $0.result == .win }.count
    }

    private var winRate: Int {
        vpipHands.isEmpty ? 0 : Int(Double(winCount) / Double(vpipHands.count) * 100)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Hero BB
                if let bb = session.totalBBResult, bb != 0 {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(String(format: "%+.0f", bb))
                            .font(.system(size: 56, weight: .ultraLight, design: .monospaced))
                            .monospacedDigit()
                            .foregroundColor(bb > 0 ? .vtAccent : .vtRed)
                        Text("BB")
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(.vtDim)
                    }
                    .padding(.top, 16)
                }

                // Basic stats
                basicStatsCard
                    .padding(.horizontal, 20)

                // Hand records
                if !vpipHands.isEmpty {
                    handsSection
                }

                Spacer().frame(height: 80)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color.vtBlack.ignoresSafeArea())
        .navigationTitle(session.dateLabel(lang))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Basic Stats

    private var basicStatsCard: some View {
        VStack(spacing: 0) {
            statRow("VPIP", value: "\(session.sessionVPIP)%")
            rowDivider
            statRow(L10n.s(.hands, lang), value: "\(session.totalHands)")
            rowDivider
            statRow(L10n.s(.vpipHands, lang), value: "\(session.vpipHands)")
            rowDivider
            statRow(L10n.s(.winRate, lang), value: "\(winCount)/\(vpipHands.count) (\(winRate)%)", color: winRate >= 50 ? .vtAccent : .vtText)
            rowDivider
            statRow(L10n.s(.duration, lang), value: session.durationFormatted(lang))

            if let bb = session.totalBBResult, session.totalHands >= 10 {
                let bb100 = (bb / Double(session.totalHands)) * 100
                rowDivider
                statRow("BB/100", value: String(format: "%+.1f", bb100), color: bb100 > 0 ? .vtAccent : bb100 < 0 ? .vtRed : .vtText)
            }

            let gto = getGTOStats()
            if gto.total >= 3 {
                rowDivider
                statRow("GTO", value: "\(gto.inRange)/\(gto.total) (\(gto.complianceRate)%)", color: gto.complianceRate >= 80 ? .vtAccent : .vtText)
            }

            rowDivider
            statRow(L10n.s(.date, lang), value: dateString, color: .vtDim)
        }
        .background(Color.vtSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.vtBorder, lineWidth: 1)
        )
    }

    private func statRow(_ title: String, value: String, color: Color = .vtText) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.vtMuted)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(color)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
    }

    private var rowDivider: some View {
        Rectangle()
            .fill(Color.vtBorder)
            .frame(height: 0.5)
            .padding(.horizontal, 16)
    }

    // MARK: - Hand Records

    private var handsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(L10n.s(.entries, lang)) (\(vpipHands.count))")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.vtDim)
                .tracking(2)
                .padding(.horizontal, 20)

            VStack(spacing: 0) {
                ForEach(Array(vpipHands.reversed().prefix(30).enumerated()), id: \.element.id) { index, hand in
                    handRow(hand)

                    if index < min(vpipHands.count, 30) - 1 {
                        Rectangle()
                            .fill(Color.vtBorder)
                            .frame(height: 0.5)
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(Color.vtSurface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.vtBorder, lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
    }

    private func handRow(_ hand: HandRecordData) -> some View {
        HStack(spacing: 8) {
            Text(hand.handType ?? "—")
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(.vtText)
                .frame(width: 40, alignment: .leading)

            Spacer()

            if let bb = hand.bbResult {
                Text(String(format: "%+.0f", bb))
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .monospacedDigit()
                    .foregroundColor(bb > 0 ? .vtAccent : bb < 0 ? .vtRed : .vtDim)
            }

            Circle()
                .fill(hand.result == .win ? Color.vtAccent : Color.white.opacity(0.1))
                .frame(width: 6, height: 6)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
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
