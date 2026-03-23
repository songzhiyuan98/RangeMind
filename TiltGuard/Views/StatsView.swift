import SwiftUI
import SwiftData

struct StatsView: View {
    @Environment(DataService.self) private var dataService
    @Environment(LanguageManager.self) private var languageManager

    private var lang: AppLanguage { languageManager.language }

    var body: some View {
        NavigationStack {
            if dataService.isGuestMode {
                guestLockedView
            } else if dataService.lifetimeHands < 10 {
                notEnoughDataView
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        // 1. Today Session Summary
                        todaySection
                            .padding(.top, 20)
                            .padding(.bottom, 28)

                        // 2. Tilt Analysis
                        tiltSection
                            .padding(.bottom, 28)

                        // 3. Play Style
                        playStyleSection
                            .padding(.bottom, 28)

                        // 4. History Trend (lifetime overview)
                        historySection

                        Spacer().frame(height: 100)
                    }
                }
                .scrollIndicators(.hidden)
                .background(Color.vtBlack.ignoresSafeArea())
                .toolbar(.hidden, for: .navigationBar)
            }
        }
    }

    // MARK: - Guest Locked

    private var guestLockedView: some View {
        VStack(spacing: 12) {
            Spacer()

            Text(L10n.s(.statsLocked, lang))
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.vtMuted)

            Text(L10n.s(.statsLockedDesc, lang))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.vtDim)

            Button {
                dataService.signInWithApple()
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
            .padding(.horizontal, 40)
            .padding(.top, 8)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.vtBlack.ignoresSafeArea())
    }

    // MARK: - Not Enough Data

    private var notEnoughDataView: some View {
        VStack(spacing: 12) {
            Spacer()

            Text(L10n.s(.noDataYet, lang))
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.vtMuted)

            Text(L10n.s(.playMoreHands, lang))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.vtDim)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.vtBlack.ignoresSafeArea())
    }

    // MARK: - 1. Today Session Summary

    private var todaySection: some View {
        let today = dataService.getTodayStats()

        return VStack(spacing: 0) {
            // Hero: discipline score or hand count
            VStack(spacing: 8) {
                if let score = today.disciplineScore {
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text("\(score)")
                            .font(.system(size: 96, weight: .ultraLight, design: .monospaced))
                            .foregroundColor(disciplineColor(score))

                        Text("/100")
                            .font(.system(size: 24, weight: .ultraLight, design: .monospaced))
                            .foregroundColor(.vtDim)
                    }

                    Text(L10n.s(.disciplineScore, lang).uppercased())
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.vtDim)
                        .tracking(2)
                } else {
                    Text("\(today.totalHands)")
                        .font(.system(size: 96, weight: .ultraLight, design: .monospaced))
                        .foregroundColor(.vtText)

                    Text(L10n.s(.todayPerformance, lang).uppercased())
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.vtDim)
                        .tracking(2)
                }
            }
            .padding(.bottom, 28)

            // Quick stats
            HStack(spacing: 0) {
                statCell("\(today.totalHands)", L10n.s(.hands, lang))
                statCell("\(today.vpip)%", "VPIP")

                if let bb = today.bbResult {
                    statCell(
                        String(format: "%+.0f", bb),
                        "BB"
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)

            // Detail rows
            sectionLabel(L10n.s(.todayPerformance, lang))
                .padding(.bottom, 12)

            VStack(spacing: 0) {
                detailRow(L10n.s(.hands, lang), "\(today.totalHands)")
                rowDivider
                detailRow("VPIP", "\(today.vpip)%")

                if let bb = today.bbResult {
                    rowDivider
                    detailRow(
                        L10n.s(.netResult, lang),
                        String(format: "%+.1f BB", bb),
                        color: bb >= 0 ? .vtText : .vtRed
                    )
                }

                if let score = today.disciplineScore {
                    rowDivider
                    detailRow(
                        L10n.s(.disciplineScore, lang),
                        "\(score)/100",
                        color: disciplineColor(score)
                    )
                }
            }
            .padding(.horizontal, 32)
        }
    }

    // MARK: - 2. Tilt Analysis

    private var tiltSection: some View {
        let today = dataService.getTodayStats()
        let analysis = dataService.getTiltAnalysis()

        return VStack(alignment: .leading, spacing: 12) {
            sectionLabel(L10n.s(.tiltAnalysis, lang))

            VStack(spacing: 0) {
                // Today's tilt events
                detailRow(L10n.s(.tiltWarnings, lang), "\(today.tiltWarnings)")
                rowDivider
                detailRow(
                    L10n.s(.tiltDangers, lang),
                    "\(today.tiltDangers)",
                    color: today.tiltDangers > 0 ? .vtRed : .vtMuted
                )
                rowDivider
                detailRow(L10n.s(.cooldownCompleted, lang), "\(today.cooldownCount)")

                // Lifetime tilt stats
                if analysis.totalSessions >= 3 {
                    rowDivider

                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 12)

                    sectionLabel(L10n.s(.tiltAnalysis, lang) + " · " + L10n.s(.lifetime, lang))
                        .padding(.bottom, 4)
                        .padding(.horizontal, -32)

                    detailRow(
                        L10n.s(.sessions, lang),
                        "\(analysis.tiltSessions)/\(analysis.totalSessions)",
                        color: tiltColor(analysis.tiltRate)
                    )
                    rowDivider
                    detailRow(
                        L10n.s(.rate, lang),
                        "\(analysis.tiltRate)%",
                        color: tiltColor(analysis.tiltRate)
                    )
                    rowDivider
                    detailRow(L10n.s(.avgDur, lang), "\(analysis.avgTiltDuration)m")

                    if analysis.tiltRate > 20 {
                        rowDivider
                        HStack {
                            Text(L10n.s(.highTiltFrequency, lang))
                                .font(.system(size: 13))
                                .foregroundColor(.vtAmber)
                            Spacer()
                        }
                        .padding(.vertical, 14)
                    }
                }
            }
            .padding(.horizontal, 32)
        }
    }

    // MARK: - 3. Play Style

    private var playStyleSection: some View {
        let today = dataService.getTodayStats()

        return VStack(alignment: .leading, spacing: 12) {
            sectionLabel(L10n.s(.playStyle, lang))

            VStack(spacing: 0) {
                // VPIP vs baseline
                detailRow("VPIP", "\(today.vpip)%")
                rowDivider
                detailRow(L10n.s(.baselineVPIP, lang), "\(dataService.lifetimeVPIP)%")

                let vpipDiff = today.totalHands >= 10 ? today.vpip - dataService.lifetimeVPIP : 0
                if vpipDiff != 0 {
                    rowDivider
                    detailRow(
                        L10n.s(.vpipDeviation, lang),
                        vpipDiff > 0 ? "+\(vpipDiff)%" : "\(vpipDiff)%",
                        color: abs(vpipDiff) > 5 ? .vtAmber : .vtMuted
                    )
                }

                // Deviation hands
                rowDivider
                detailRow(
                    L10n.s(.deviationHands, lang),
                    "\(today.deviationCount)",
                    color: today.deviationCount > 3 ? .vtAmber : .vtMuted
                )

                // Weak entries
                rowDivider
                detailRow(
                    L10n.s(.weakHandEntries, lang),
                    "\(today.weakEntryCount)",
                    color: today.weakEntryCount > 2 ? .vtRed : .vtMuted
                )
            }
            .padding(.horizontal, 32)
        }
    }

    // MARK: - 4. History / Lifetime

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel(L10n.s(.statistics, lang))

            VStack(spacing: 0) {
                detailRow(L10n.s(.hands, lang), "\(dataService.lifetimeHands)")
                rowDivider
                detailRow(L10n.s(.sessions, lang), "\(dataService.recentSessions.count)")
                rowDivider
                detailRow("VPIP", "\(dataService.lifetimeVPIP)%")

                if dataService.lifetimeHands >= 100 {
                    let playerType = PlayerType.from(vpip: dataService.lifetimeVPIP)
                    rowDivider
                    HStack {
                        Text(playerType.rawValue)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.vtText)

                        Spacer()

                        HStack(spacing: 6) {
                            Circle()
                                .fill(playerType.color)
                                .frame(width: 5, height: 5)
                            Text(playerType.description)
                                .font(.system(size: 13))
                                .foregroundColor(.vtDim)
                        }
                    }
                    .padding(.vertical, 14)
                }

                if dataService.totalBBResult != 0 {
                    rowDivider
                    detailRow(
                        L10n.s(.totalBB, lang),
                        String(format: "%+.1f", dataService.totalBBResult),
                        color: dataService.totalBBResult >= 0 ? .vtText : .vtRed
                    )
                }

                if dataService.lifetimeHands >= 100 {
                    rowDivider
                    detailRow(
                        L10n.s(.bb100, lang),
                        String(format: "%+.1f", dataService.bb100),
                        color: dataService.bb100 >= 0 ? .vtText : .vtRed
                    )
                }
            }
            .padding(.horizontal, 32)
        }
    }

    // MARK: - Helpers

    private func disciplineColor(_ score: Int) -> Color {
        score >= 80 ? .vtText : score >= 60 ? .vtAmber : .vtRed
    }

    private func tiltColor(_ rate: Int) -> Color {
        rate > 30 ? .vtRed : rate > 15 ? .vtAmber : .vtText
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .medium, design: .monospaced))
            .foregroundColor(.vtDim)
            .tracking(2)
            .padding(.horizontal, 32)
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

    private func detailRow(_ title: String, _ value: String, color: Color = .vtMuted) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.vtText)

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .medium, design: .monospaced))
                .foregroundColor(color)
        }
        .padding(.vertical, 14)
    }

    private var rowDivider: some View {
        Rectangle()
            .fill(Color.vtBorder)
            .frame(height: 0.5)
    }
}

#Preview {
    StatsView()
        .environment(DataService(modelContext: PreviewContainer.shared.mainContext))
        .environment(LanguageManager())
        .preferredColorScheme(.dark)
}
