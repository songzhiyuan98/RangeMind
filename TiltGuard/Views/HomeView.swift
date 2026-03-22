import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(DataService.self) private var dataService
    @Environment(LanguageManager.self) private var languageManager
    @Binding var selectedTab: Int

    @State private var selectedStrategy: PokerStrategy = .balanced
    @State private var backgroundPhase: CGFloat = 0

    private var lang: AppLanguage { languageManager.language }

    var body: some View {
        NavigationStack {
            ZStack {
                // Animated gradient background
                backgroundLayer
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        header
                            .padding(.top, 12)
                            .padding(.bottom, 24)

                        // VPIP Dial
                        dialSection
                            .padding(.bottom, 28)

                        // Strategy buttons
                        strategyButtons
                            .padding(.bottom, 20)

                        // Strategy insight card
                        StrategyInsightCard(
                            strategy: selectedStrategy,
                            currentVPIP: dataService.lifetimeVPIP,
                            lang: lang
                        )
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)

                        // Quick stats bar
                        quickStatsBar
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)

                        // Start / Continue button
                        startButton
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)

                        // Recent Sessions
                        recentSection
                            .padding(.bottom, 100)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        ZStack {
            // Base dark
            Color.black

            // Gradient mesh
            LinearGradient(
                colors: [
                    Color(hex: "0A0012"),
                    Color(hex: "0D0620"),
                    Color(hex: "08001A"),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Ambient glow - top
            RadialGradient(
                colors: [
                    Color.vtAccent.opacity(0.08),
                    Color.clear
                ],
                center: .init(x: 0.5, y: 0.2),
                startRadius: 50,
                endRadius: 300
            )

            // Ambient glow - bottom accent
            RadialGradient(
                colors: [
                    Color(hex: "1A0533").opacity(0.5),
                    Color.clear
                ],
                center: .init(x: 0.3, y: 0.8),
                startRadius: 20,
                endRadius: 250
            )
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 0) {
                    Text("Range")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)

                    Text("Mind")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.vtAccent, .vtAccent.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }

            Spacer()

            if dataService.lifetimeHands >= 100 {
                glassPlayerBadge
            }
        }
        .padding(.horizontal, 24)
    }

    private var glassPlayerBadge: some View {
        let type = PlayerType.from(vpip: dataService.lifetimeVPIP)
        return HStack(spacing: 6) {
            Circle()
                .fill(type.color)
                .frame(width: 5, height: 5)
                .shadow(color: type.color.opacity(0.6), radius: 4)

            Text(type.rawValue)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    // MARK: - Dial Section

    private var dialSection: some View {
        LiquidGlassDial(
            vpipValue: dataService.lifetimeVPIP,
            targetValue: selectedStrategy.vpipTarget,
            label: L10n.s(.currentVPIP, lang),
            isBuilding: dataService.lifetimeHands < 10,
            handsPlayed: dataService.lifetimeHands,
            handsRequired: 10
        )
    }

    // MARK: - Strategy Buttons

    private var strategyButtons: some View {
        HStack(spacing: 28) {
            ForEach(PokerStrategy.allCases, id: \.self) { strategy in
                StrategyButton(
                    strategy: strategy,
                    isSelected: selectedStrategy == strategy,
                    lang: lang
                ) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedStrategy = strategy
                    }
                }
            }
        }
    }

    // MARK: - Quick Stats Bar

    private var quickStatsBar: some View {
        HStack(spacing: 0) {
            glassStatCell("\(dataService.lifetimeHands)", L10n.s(.hands, lang))

            glassStatDivider

            glassStatCell("\(dataService.recentSessions.count)", L10n.s(.sessions, lang))

            glassStatDivider

            let totalBB = dataService.totalBBResult
            glassStatCell(
                totalBB != 0 ? String(format: "%+.0f", totalBB) : "--",
                "BB",
                color: totalBB > 0 ? .vtAccent : totalBB < 0 ? .vtRed : .white.opacity(0.6)
            )

            if dataService.lifetimeHands >= 100 {
                glassStatDivider
                let bb100 = dataService.bb100
                glassStatCell(
                    String(format: "%.1f", bb100),
                    "BB/100",
                    color: bb100 > 0 ? .vtAccent : bb100 < 0 ? .vtRed : .white.opacity(0.6)
                )
            }
        }
        .padding(.vertical, 16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)

                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.06),
                                Color.white.opacity(0.02)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private func glassStatCell(_ value: String, _ label: String, color: Color = .white.opacity(0.85)) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .medium, design: .monospaced))
                .monospacedDigit()
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.3))
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
    }

    private var glassStatDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .frame(width: 1, height: 28)
    }

    // MARK: - Start Button

    private var startButton: some View {
        Button {
            if !dataService.hasActiveSession {
                dataService.startSession()
            }
            selectedTab = 1
        } label: {
            HStack(spacing: 10) {
                Image(systemName: dataService.hasActiveSession ? "play.fill" : "plus")
                    .font(.system(size: 14, weight: .semibold))

                Text(L10n.s(dataService.hasActiveSession ? .continueSession : .startSession, lang))
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .tracking(1.5)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.vtAccent,
                                    Color.vtAccent.opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // Glass shine
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }
            )
            .shadow(color: .vtAccent.opacity(0.4), radius: 16, x: 0, y: 6)
        }
        .buttonStyle(GlassButtonStyle())
    }

    // MARK: - Recent Sessions

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !dataService.recentSessions.isEmpty {
                HStack {
                    Text(L10n.s(.recent, lang))
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.3))
                        .tracking(2)

                    Spacer()

                    if dataService.recentSessions.count > 5 {
                        NavigationLink {
                            AllSessionsView()
                        } label: {
                            Text(L10n.s(.viewAll, lang))
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.vtAccent.opacity(0.7))
                                .tracking(1)
                        }
                    }
                }
                .padding(.horizontal, 24)

                VStack(spacing: 0) {
                    let sessions = Array(dataService.recentSessions.prefix(6))
                    ForEach(Array(sessions.enumerated()), id: \.element.id) { index, session in
                        NavigationLink {
                            SessionDetailView(session: session)
                        } label: {
                            sessionRow(session)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(role: .destructive) {
                                withAnimation {
                                    dataService.deleteSession(session)
                                }
                            } label: {
                                Label(L10n.s(.delete, lang), systemImage: "trash")
                            }
                        }

                        if index < sessions.count - 1 {
                            Rectangle()
                                .fill(Color.white.opacity(0.06))
                                .frame(height: 0.5)
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.ultraThinMaterial)

                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.05),
                                        Color.white.opacity(0.02)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .padding(.horizontal, 24)
            }
        }
    }

    private func sessionRow(_ session: SessionData) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(session.dateLabel(lang))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))

                Text("\(session.totalHands) \(L10n.s(.handsCount, lang)) · \(session.durationFormatted(lang))")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.white.opacity(0.35))
            }

            Spacer()

            HStack(spacing: 12) {
                if let bb = session.totalBBResult, bb != 0 {
                    Text(String(format: "%+.0f", bb))
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .monospacedDigit()
                        .foregroundColor(bb > 0 ? .vtAccent : .vtRed)
                }

                Text("\(session.sessionVPIP)%")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .monospacedDigit()
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
        .environment(DataService(modelContext: PreviewContainer.shared.mainContext))
        .environment(LanguageManager())
        .preferredColorScheme(.dark)
}
