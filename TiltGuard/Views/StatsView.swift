import SwiftUI
import SwiftData

struct StatsView: View {
    @Environment(DataService.self) private var dataService
    @Environment(LanguageManager.self) private var languageManager

    private var lang: AppLanguage { languageManager.language }

    var body: some View {
        NavigationStack {
            if dataService.isGuestMode {
                // Guest locked state
                VStack(spacing: 20) {
                    Spacer()

                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 48, weight: .ultraLight))
                        .foregroundColor(.vtDim)

                    Text(L10n.s(.statsLocked, lang))
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.vtMuted)

                    Text(L10n.s(.statsLockedDesc, lang))
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.vtDim)

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
                    .padding(.horizontal, 40)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.vtBlack.ignoresSafeArea())
            } else if dataService.lifetimeHands < 10 {
                // Not enough data
                VStack(spacing: 20) {
                    Spacer()

                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 48, weight: .ultraLight))
                        .foregroundColor(.vtDim)

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
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        statsHeader
                            .padding(.top, 20)

                        // BB Stats
                        bbSection

                        // GTO Compliance
                        gtoComplianceSection

                        // Tilt Analysis
                        tiltAnalysisSection

                        Spacer().frame(height: 100)
                    }
                }
                .scrollIndicators(.hidden)
                .background(Color.vtBlack.ignoresSafeArea())
                .toolbar(.hidden, for: .navigationBar)
            }
        }
    }

    // MARK: - Header

    private var statsHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.s(.statistics, lang))
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.vtDim)
                .tracking(3)
                .padding(.horizontal, 20)

            if dataService.lifetimeHands >= 100 {
                let playerType = PlayerType.from(vpip: dataService.lifetimeVPIP)

                HStack(spacing: 8) {
                    Circle()
                        .fill(playerType.color)
                        .frame(width: 5, height: 5)

                    Text("\(playerType.rawValue) · \(dataService.lifetimeVPIP)% · \(dataService.lifetimeHands) \(L10n.s(.handsCount, lang))")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.vtMuted)
                }
                .padding(.horizontal, 20)

                Text(playerType.description)
                    .font(.system(size: 12))
                    .foregroundColor(.vtDim)
                    .padding(.horizontal, 20)
            } else {
                HStack(spacing: 8) {
                    Text("\(dataService.lifetimeVPIP)% · \(dataService.lifetimeHands) \(L10n.s(.handsCount, lang))")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.vtMuted)
                }
                .padding(.horizontal, 20)

                Text(L10n.s(.playerProfileUnlocks, lang))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.vtDim)
                    .padding(.horizontal, 20)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - BB Stats

    private var bbSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(L10n.s(.bbStats, lang))

            HStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text(String(format: "%+.1f", dataService.totalBBResult))
                        .font(.system(size: 28, weight: .light, design: .monospaced))
                        .monospacedDigit()
                        .foregroundColor(dataService.totalBBResult >= 0 ? .vtAccent : .vtRed)

                    Text(L10n.s(.totalBB, lang))
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundColor(.vtDim)
                        .tracking(1)
                }
                .frame(maxWidth: .infinity)

                Rectangle()
                    .fill(Color.vtBorder)
                    .frame(width: 1, height: 40)

                VStack(spacing: 4) {
                    Text(String(format: "%+.1f", dataService.bb100))
                        .font(.system(size: 28, weight: .light, design: .monospaced))
                        .monospacedDigit()
                        .foregroundColor(dataService.bb100 >= 0 ? .vtAccent : .vtRed)

                    Text(L10n.s(.bb100, lang))
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundColor(.vtDim)
                        .tracking(1)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 20)
            .background(Color.vtSurface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.vtBorder, lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
    }

    // MARK: - GTO Compliance

    private var gtoComplianceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(L10n.s(.gtoCompliance, lang))

            let stats = dataService.getGTOComplianceStats()

            VStack(spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Text("\(stats.complianceRate)")
                                .font(.system(size: 40, weight: .ultraLight, design: .monospaced))
                                .foregroundColor(stats.isGood ? .vtAccent : stats.complianceRate >= 60 ? .vtAmber : .vtRed)

                            Text("%")
                                .font(.system(size: 16, weight: .ultraLight, design: .monospaced))
                                .foregroundColor(.vtDim)
                        }

                        Text(L10n.s(.inRange, lang))
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(.vtDim)
                            .tracking(1)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 6) {
                        HStack(spacing: 4) {
                            Text("\(stats.inRangeCount)")
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                                .foregroundColor(.vtAccent)
                            Text(L10n.s(.std, lang))
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.vtDim)
                        }

                        HStack(spacing: 4) {
                            Text("\(stats.outOfRangeCount)")
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                                .foregroundColor(.vtAmber)
                            Text(L10n.s(.dev, lang))
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.vtDim)
                        }
                    }
                }

                if !stats.topDeviations.isEmpty {
                    Rectangle()
                        .fill(Color.vtBorder)
                        .frame(height: 0.5)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(L10n.s(.common_deviations, lang))
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(.vtDim)
                            .tracking(1)

                        HStack(spacing: 6) {
                            ForEach(stats.topDeviations, id: \.self) { hand in
                                Text(hand)
                                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.vtAmber)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.vtAmber.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                            Spacer()
                        }
                    }
                }

                if !stats.isGood && stats.totalAnalyzed >= 10 {
                    HStack(spacing: 6) {
                        Text("→")
                            .foregroundColor(.vtAmber)
                        Text(L10n.s(.tightenRange, lang))
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.vtMuted)
                        Spacer()
                    }
                }
            }
            .padding(16)
            .background(Color.vtSurface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.vtBorder, lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Tilt Analysis

    private var tiltAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(L10n.s(.tiltAnalysis, lang))

            let analysis = dataService.getTiltAnalysis()

            VStack(spacing: 14) {
                HStack(spacing: 0) {
                    VStack(spacing: 3) {
                        Text("\(analysis.tiltSessions)/\(analysis.totalSessions)")
                            .font(.system(size: 20, weight: .light, design: .monospaced))
                            .foregroundColor(tiltColor(analysis.tiltRate))

                        Text(L10n.s(.sessions, lang))
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(.vtDim)
                            .tracking(1)
                    }
                    .frame(maxWidth: .infinity)

                    Rectangle()
                        .fill(Color.vtBorder)
                        .frame(width: 1, height: 32)

                    VStack(spacing: 3) {
                        Text("\(analysis.tiltRate)%")
                            .font(.system(size: 20, weight: .light, design: .monospaced))
                            .foregroundColor(tiltColor(analysis.tiltRate))

                        Text(L10n.s(.rate, lang))
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(.vtDim)
                            .tracking(1)
                    }
                    .frame(maxWidth: .infinity)

                    Rectangle()
                        .fill(Color.vtBorder)
                        .frame(width: 1, height: 32)

                    VStack(spacing: 3) {
                        Text("\(analysis.avgTiltDuration)m")
                            .font(.system(size: 20, weight: .light, design: .monospaced))
                            .foregroundColor(.vtText)

                        Text(L10n.s(.avgDur, lang))
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(.vtDim)
                            .tracking(1)
                    }
                    .frame(maxWidth: .infinity)
                }

                if analysis.tiltRate > 20 {
                    Text("→ \(L10n.s(.highTiltFrequency, lang))")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.vtAmber)
                }
            }
            .padding(16)
            .background(Color.vtSurface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.vtBorder, lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
    }

    private func tiltColor(_ rate: Int) -> Color {
        rate > 30 ? .vtRed : rate > 15 ? .vtAmber : .vtAccent
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .medium, design: .monospaced))
            .foregroundColor(.vtDim)
            .tracking(2)
            .padding(.horizontal, 20)
    }
}

#Preview {
    StatsView()
        .environment(DataService(modelContext: PreviewContainer.shared.mainContext))
        .environment(LanguageManager())
        .preferredColorScheme(.dark)
}
