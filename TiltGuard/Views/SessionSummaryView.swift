import SwiftUI
import SwiftData

struct SessionSummaryView: View {
    let session: SessionData
    @Environment(DataService.self) private var dataService
    @Environment(LanguageManager.self) private var languageManager
    @Environment(\.dismiss) private var dismiss

    private var lang: AppLanguage { languageManager.language }

    private var allHands: [HandRecordData] { session.handRecords }
    private var vpipHands: [HandRecordData] { allHands.filter { $0.didVPIP } }
    private var foldHands: [HandRecordData] { allHands.filter { !$0.didVPIP } }
    private var winCount: Int { vpipHands.filter { $0.result == .win }.count }
    private var vpipDeviation: Int { session.sessionVPIP - dataService.lifetimeVPIP }
    private var weakEntryCount: Int { allHands.filter { $0.didVPIP && $0.isGTODeviation == true }.count }

    private var emotionCounts: (badBeat: Int, cooler: Int, tilt: Int) {
        var bb = 0, co = 0, ti = 0
        for hand in allHands {
            switch hand.emotionSignal {
            case .badBeat: bb += 1
            case .cooler: co += 1
            case .tilt: ti += 1
            case nil: break
            }
        }
        return (bb, co, ti)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero
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

                    // Guest prompt
                    if dataService.isGuestMode {
                        guestLoginPrompt
                            .padding(.top, 12)
                    }

                    Spacer().frame(height: 40)
                }
            }
            .scrollIndicators(.hidden)
            .background(Color.vtBlack.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text(L10n.s(.done, lang))
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.vtText)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                }
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 8) {
            if let bbResult = session.totalBBResult, bbResult != 0 {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(String(format: "%+.0f", bbResult))
                        .font(.system(size: 96, weight: .ultraLight, design: .monospaced))
                        .foregroundColor(.vtText)

                    Text("BB")
                        .font(.system(size: 32, weight: .ultraLight, design: .monospaced))
                        .foregroundColor(.vtDim)
                }

                Text(L10n.s(.sessionComplete, lang))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.vtDim)
                    .tracking(2)
            } else {
                Text("\(session.totalHands)")
                    .font(.system(size: 96, weight: .ultraLight, design: .monospaced))
                    .foregroundColor(.vtText)

                Text(L10n.s(.sessionComplete, lang))
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

                if dataService.lifetimeHands >= 20 {
                    rowDivider
                    let devStr = vpipDeviation >= 0 ? "+\(vpipDeviation)%" : "\(vpipDeviation)%"
                    detailRow(L10n.s(.vpipDeviation, lang), devStr)
                }

                if weakEntryCount > 0 {
                    rowDivider
                    detailRow(L10n.s(.weakEntries, lang), "\(weakEntryCount)")
                }

                let emotions = emotionCounts
                if emotions.badBeat > 0 {
                    rowDivider
                    detailRow("Bad Beat", "\(emotions.badBeat)")
                }
                if emotions.cooler > 0 {
                    rowDivider
                    detailRow("Cooler", "\(emotions.cooler)")
                }
                if emotions.tilt > 0 {
                    rowDivider
                    detailRow("Tilt", "\(emotions.tilt)")
                }

                rowDivider
                detailRow(L10n.s(.tableSizeLabel, lang), session.tableInfoLabel(lang))
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

    // MARK: - Guest Login Prompt

    private var guestLoginPrompt: some View {
        VStack(spacing: 16) {
            Text(L10n.s(.saveThisSession, lang))
                .font(.system(size: 15))
                .foregroundColor(.vtMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                dataService.signInWithApple()
            } label: {
                Text(L10n.s(.signInWithApple, lang))
                    .font(.system(size: 16, weight: .semibold))
                    .tracking(0.5)
                    .foregroundColor(.vtBlack)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.vtText)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    let session = SessionData(
        startTime: Date().addingTimeInterval(-3600),
        endTime: Date(),
        totalHands: 45,
        vpipHands: 11
    )
    return SessionSummaryView(session: session)
        .preferredColorScheme(.dark)
}
