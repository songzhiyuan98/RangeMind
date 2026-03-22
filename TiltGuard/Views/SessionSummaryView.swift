import SwiftUI
import SwiftData

struct SessionSummaryView: View {
    let session: SessionData
    @Environment(DataService.self) private var dataService
    @Environment(LanguageManager.self) private var languageManager
    @Environment(\.dismiss) private var dismiss

    private var lang: AppLanguage { languageManager.language }

    // MARK: - Computed Data

    private var vpipHands: [HandRecordData] {
        session.handRecords.filter { $0.didVPIP }
    }

    private var vpipDeviation: Int {
        session.sessionVPIP - dataService.lifetimeVPIP
    }

    private var controlRating: (label: String, grade: String, color: Color) {
        let dev = abs(vpipDeviation)
        if dev < 3 {
            return (L10n.s(.excellent, lang), "A", .vtAccent)
        } else if dev < 6 {
            return (L10n.s(.good, lang), "B", .vtAccent)
        } else if dev < 10 {
            return (L10n.s(.loose, lang), "C", .vtAmber)
        } else {
            return (L10n.s(.veryLoose, lang), "D", .vtRed)
        }
    }

    private var tiltAlertCount: Int {
        // Count hands that were GTO deviations as proxy for tilt events
        let records = session.handRecords
        var alerts = 0
        // Check for sequences of deviations
        var consecutiveDeviations = 0
        for record in records {
            if record.isGTODeviation == true {
                consecutiveDeviations += 1
                if consecutiveDeviations == 3 { alerts += 1 }
            } else {
                consecutiveDeviations = 0
            }
        }
        return alerts
    }

    private var weakEntryCount: Int {
        session.handRecords.filter { $0.didVPIP && $0.isGTODeviation == true }.count
    }

    private var gtoDeviationCount: Int {
        session.handRecords.filter { $0.isGTODeviation == true }.count
    }

    private var disciplineGrade: (grade: String, color: Color) {
        let dev = abs(vpipDeviation)
        let weakRatio = session.totalHands > 0 ? Double(weakEntryCount) / Double(session.totalHands) * 100 : 0

        // Combined scoring
        var score = 100
        if dev >= 10 { score -= 40 }
        else if dev >= 6 { score -= 25 }
        else if dev >= 3 { score -= 10 }

        if weakRatio >= 15 { score -= 30 }
        else if weakRatio >= 10 { score -= 20 }
        else if weakRatio >= 5 { score -= 10 }

        score -= tiltAlertCount * 10

        if score >= 90 { return ("A", .vtAccent) }
        if score >= 75 { return ("B+", .vtAccent) }
        if score >= 60 { return ("B", .vtAccent) }
        if score >= 45 { return ("C+", .vtAmber) }
        if score >= 30 { return ("C", .vtAmber) }
        return ("D", .vtRed)
    }

    private var sessionInsightText: String {
        let dev = abs(vpipDeviation)
        if dev < 6 && weakEntryCount <= 2 {
            return L10n.s(.insightNormal, lang)
        } else if tiltAlertCount > 0 && weakEntryCount <= 3 {
            return L10n.s(.insightRecovered, lang)
        } else {
            return L10n.s(.insightTilted, lang)
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                        .padding(.top, 24)

                    // 1. Session Overview
                    sectionLabel(L10n.s(.sessionOverview, lang))
                    overviewCard

                    // 2. VPIP Control
                    sectionLabel(L10n.s(.vpipControl, lang))
                    vpipControlCard

                    // 3. Range Discipline
                    if session.totalHands >= 10 {
                        sectionLabel(L10n.s(.rangeDiscipline, lang))
                        rangeDisciplineCard
                    }

                    // 4. Session Insight
                    if session.totalHands >= 15 {
                        sectionLabel(L10n.s(.sessionInsight, lang))
                        insightCard
                    }

                    // Guest login prompt
                    if dataService.isGuestMode {
                        guestLoginPrompt
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
                        Text(L10n.s(.done, lang).uppercased())
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(.vtAccent)
                            .tracking(1)
                    }
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            // Discipline grade
            ZStack {
                Circle()
                    .stroke(disciplineGrade.color.opacity(0.2), lineWidth: 3)
                    .frame(width: 64, height: 64)

                Circle()
                    .trim(from: 0, to: gradeProgress)
                    .stroke(disciplineGrade.color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 64, height: 64)
                    .rotationEffect(.degrees(-90))

                Text(disciplineGrade.grade)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(disciplineGrade.color)
            }

            Text(L10n.s(.sessionRating, lang))
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(.vtDim)
                .tracking(2)

            Text(session.durationFormatted(lang))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.vtDim)
        }
    }

    private var gradeProgress: CGFloat {
        switch disciplineGrade.grade {
        case "A": return 1.0
        case "B+": return 0.85
        case "B": return 0.7
        case "C+": return 0.55
        case "C": return 0.4
        default: return 0.25
        }
    }

    // MARK: - Section Label

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .medium, design: .monospaced))
            .foregroundColor(.vtDim)
            .tracking(2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 4)
    }

    // MARK: - 1. Session Overview

    private var overviewCard: some View {
        VStack(spacing: 0) {
            // BB result hero (if available)
            if let bbResult = session.totalBBResult, bbResult != 0 {
                VStack(spacing: 2) {
                    Text(String(format: "%+.0f", bbResult))
                        .font(.system(size: 36, weight: .ultraLight, design: .monospaced))
                        .monospacedDigit()
                        .foregroundColor(bbResult >= 0 ? .vtAccent : .vtRed)

                    Text("BB")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.vtDim)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)

                cardDivider
            }

            statsRow(L10n.s(.handsPlayed, lang), "\(session.totalHands)")
            cardDivider
            statsRow("VPIP", "\(session.sessionVPIP)%")
            cardDivider
            statsRow(L10n.s(.duration, lang), session.durationFormatted(lang))

            if dataService.lifetimeHands >= 20 {
                cardDivider
                statsRow(L10n.s(.lifetime, lang), "\(dataService.lifetimeVPIP)%")
            }
        }
        .cardStyle()
    }

    // MARK: - 2. VPIP Control

    private var vpipControlCard: some View {
        VStack(spacing: 0) {
            // Deviation + Rating
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.s(.vpipDeviation, lang))
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundColor(.vtDim)
                        .tracking(1)

                    Text(vpipDeviation >= 0 ? "+\(vpipDeviation)%" : "\(vpipDeviation)%")
                        .font(.system(size: 28, weight: .light, design: .monospaced))
                        .foregroundColor(abs(vpipDeviation) < 6 ? .vtText : (vpipDeviation > 0 ? .vtRed : .vtAccent))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(L10n.s(.controlRating, lang))
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundColor(.vtDim)
                        .tracking(1)

                    HStack(spacing: 6) {
                        Text(controlRating.grade)
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(controlRating.color)

                        Text(controlRating.label)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.vtMuted)
                    }
                }
            }
            .padding(16)

            // Comparison to lifetime
            if dataService.lifetimeHands >= 20 {
                cardDivider

                HStack {
                    Text(L10n.s(.comparedToAvg, lang))
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.vtDim)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: vpipDeviation > 0 ? "arrow.up.right" : vpipDeviation < 0 ? "arrow.down.right" : "equal")
                            .font(.system(size: 10))
                            .foregroundColor(abs(vpipDeviation) < 3 ? .vtAccent : (vpipDeviation > 0 ? .vtRed : .vtAccent))

                        Text("\(session.sessionVPIP)% vs \(dataService.lifetimeVPIP)%")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(.vtMuted)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .cardStyle()
    }

    // MARK: - 3. Range Discipline

    private var rangeDisciplineCard: some View {
        VStack(spacing: 0) {
            statsRow(L10n.s(.weakEntries, lang), "\(weakEntryCount)")

            if gtoDeviationCount > weakEntryCount {
                cardDivider
                statsRow(L10n.s(.tiltEvents, lang), "\(gtoDeviationCount)")
            }

            // Tilt events detail
            let tiltHandRecords = session.handRecords.filter { $0.didVPIP && $0.isGTODeviation == true }
            if !tiltHandRecords.isEmpty {
                cardDivider

                VStack(spacing: 0) {
                    ForEach(Array(tiltHandRecords.prefix(5).enumerated()), id: \.element.id) { index, hand in
                        let handIndex = session.handRecords.firstIndex(where: { $0.id == hand.id }).map { $0 + 1 } ?? 0
                        HStack(spacing: 8) {
                            Text("#\(handIndex)")
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundColor(.vtDim)
                                .frame(width: 30, alignment: .leading)

                            Text(hand.handType ?? "—")
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                .foregroundColor(.vtText)

                            Spacer()

                            if let bb = hand.bbResult {
                                Text(String(format: "%+.0f", bb))
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                                    .foregroundColor(bb >= 0 ? .vtAccent : .vtRed)
                            } else if hand.result == .win {
                                Text("W")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(.vtAccent)
                            } else {
                                Text("L")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(.vtDim)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)

                        if index < min(tiltHandRecords.count, 5) - 1 {
                            cardDivider
                        }
                    }
                }
            }
        }
        .cardStyle()
    }

    // MARK: - 4. Session Insight

    private var insightCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(sessionInsightText)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.vtMuted)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.vtSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.vtBorder, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Helpers

    private func statsRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.vtMuted)

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundColor(.vtText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var cardDivider: some View {
        Rectangle()
            .fill(Color.vtBorder)
            .frame(height: 0.5)
            .padding(.horizontal, 16)
    }

    // MARK: - Guest Login Prompt

    private var guestLoginPrompt: some View {
        VStack(spacing: 16) {
            Rectangle()
                .fill(Color.vtBorder)
                .frame(height: 0.5)
                .padding(.horizontal, 40)

            VStack(spacing: 8) {
                Text(L10n.s(.saveThisSession, lang))
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(.vtMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Button {
                // TODO: Sign in with Apple
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 14))

                    Text(L10n.s(.signInWithApple, lang))
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .tracking(1)
                }
                .foregroundColor(.vtBlack)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.vtText, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 20)
        }
        .padding(.top, 16)
    }
}

// MARK: - Card Style Modifier

private extension View {
    func cardStyle() -> some View {
        self
            .background(Color.vtSurface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.vtBorder, lineWidth: 1)
            )
            .padding(.horizontal, 20)
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
