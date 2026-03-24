import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(DataService.self) private var dataService
    @Environment(LanguageManager.self) private var languageManager
    @Binding var selectedTab: Int
    @State private var showSessionSetup = false
    @State private var selectedGameMode: GameMode = .cash
    @State private var selectedTableSize: TableSize = .sixMax
    @State private var selectedPokerTableStyle: PokerTableStyle = .standard
    @State private var sessionTitle: String = ""

    private var lang: AppLanguage { languageManager.language }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Top bar
                    topBar
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    // VPIP number
                    heroSection
                        .padding(.top, 20)
                        .padding(.bottom, 28)

                    // Stats
                    quickStats
                        .padding(.horizontal, 20)
                        .padding(.bottom, 28)

                    // Start button
                    Button {
                        if dataService.hasActiveSession {
                            selectedTab = 1
                        } else {
                            showSessionSetup = true
                        }
                    } label: {
                        Text(L10n.s(dataService.hasActiveSession ? .continueSession : .startSession, lang))
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
                    .padding(.bottom, 32)

                    // Recent
                    recentSection
                        .padding(.bottom, 20)
                }
            }
            .scrollIndicators(.hidden)
            .background(Color.vtBlack.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showSessionSetup) {
                sessionSetupSheet
            }
        }
    }

    // MARK: - Session Setup Sheet

    private var sessionSetupSheet: some View {
        VStack(spacing: 24) {
            // Drag indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.vtBorder)
                .frame(width: 36, height: 4)
                .padding(.top, 12)

            Text(L10n.s(.startSession, lang))
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.vtText)

            // Session title (optional)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Text(L10n.s(.sessionTitleLabel, lang))
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.vtDim)
                        .tracking(2)

                    Text("(\(L10n.s(.optional, lang)))")
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .foregroundColor(.vtDim.opacity(0.5))
                }

                TextField("", text: $sessionTitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.vtText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.vtSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.vtBorder, lineWidth: 1)
                    )
            }

            // 1. Game Mode
            setupPickerSection(
                label: L10n.s(.gameModeLabel, lang),
                items: GameMode.allCases,
                selected: $selectedGameMode,
                nameFor: { L10n.gameModeName($0, lang) }
            )

            // 2. Table Size
            setupPickerSection(
                label: L10n.s(.tableSizeLabel, lang),
                items: TableSize.allCases,
                selected: $selectedTableSize,
                nameFor: { L10n.tableSizeName($0, lang) }
            )

            // 3. Table Style
            setupPickerSection(
                label: L10n.s(.tableStyleLabel, lang),
                items: PokerTableStyle.allCases,
                selected: $selectedPokerTableStyle,
                nameFor: { L10n.tableStyleName($0, lang) }
            )

            Spacer()

            // Start button
            Button {
                let trimmedTitle = sessionTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                dataService.startSession(
                    title: trimmedTitle.isEmpty ? nil : trimmedTitle,
                    gameMode: selectedGameMode,
                    tableSize: selectedTableSize,
                    tableStyle: selectedPokerTableStyle
                )
                sessionTitle = ""
                showSessionSetup = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = 1
                    }
                }
            } label: {
                Text(L10n.s(.startSession, lang))
                    .font(.system(size: 16, weight: .semibold))
                    .tracking(0.5)
                    .foregroundColor(.vtBlack)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.vtText)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .background(Color.vtBlack.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.2), value: selectedGameMode)
        .animation(.easeInOut(duration: 0.2), value: selectedTableSize)
    }

    /// Reusable picker row for setup sheet
    private func setupPickerSection<T: Identifiable & Equatable>(
        label: String,
        items: [T],
        selected: Binding<T>,
        nameFor: @escaping (T) -> String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.vtDim)
                .tracking(2)

            HStack(spacing: 6) {
                ForEach(items) { item in
                    let isSelected = selected.wrappedValue == item
                    Button {
                        selected.wrappedValue = item
                    } label: {
                        Text(nameFor(item))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(isSelected ? .vtBlack : .vtMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                            .background(isSelected ? Color.vtText : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(isSelected ? Color.clear : Color.vtBorder, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            // Left: player type or hands count
            if dataService.lifetimeHands >= 10 {
                let playerType = PlayerType.from(vpip: dataService.lifetimeVPIP)
                HStack(spacing: 6) {
                    Circle()
                        .fill(playerType.color)
                        .frame(width: 5, height: 5)
                    Text(playerType.displayName(lang))
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.vtDim)
                }
            } else {
                Text("\(dataService.lifetimeHands) / 10")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.vtDim)
            }

            Spacer()

            // Right: live session indicator
            if dataService.hasActiveSession {
                Button {
                    selectedTab = 1
                } label: {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.vtGreen)
                            .frame(width: 5, height: 5)
                        Text("LIVE · \(dataService.sessionHands)")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(.vtDim)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(Color.vtBorder, lineWidth: 1)
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 8) {
            if dataService.lifetimeHands >= 10 {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("\(dataService.lifetimeVPIP)")
                        .font(.system(size: 96, weight: .ultraLight, design: .monospaced))
                        .foregroundColor(.vtText)
                        .contentTransition(.numericText())

                    Text("%")
                        .font(.system(size: 32, weight: .ultraLight, design: .monospaced))
                        .foregroundColor(.vtDim)
                }

                Text(L10n.s(.lifetimeVPIP, lang))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.vtDim)
                    .tracking(2)
            } else {
                Text("—")
                    .font(.system(size: 80, weight: .ultraLight, design: .monospaced))
                    .foregroundColor(.vtDim)

                Text(L10n.s(.buildingProfile, lang))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.vtDim)
                    .tracking(2)

                Text("\(dataService.lifetimeHands) / 10 \(L10n.s(.handsProgress, lang))")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.vtDim)
            }
        }
    }

    // MARK: - Quick Stats

    private var quickStats: some View {
        HStack(spacing: 0) {
            statCell("\(dataService.lifetimeHands)", L10n.s(.hands, lang))

            statCell("\(dataService.recentSessions.count)", L10n.s(.sessions, lang))

            let totalBB = dataService.totalBBResult
            statCell(
                totalBB != 0 ? String(format: "%+.0f", totalBB) : "—",
                "BB",
                color: totalBB > 0 ? .vtAccent : totalBB < 0 ? .vtRed : .vtText
            )

            if dataService.lifetimeHands >= 100 {
                let bb100 = dataService.bb100
                statCell(
                    String(format: "%.1f", bb100),
                    "BB/100",
                    color: bb100 > 0 ? .vtAccent : bb100 < 0 ? .vtRed : .vtText
                )
            }
        }
    }

    private func statCell(_ value: String, _ label: String, color: Color = .vtText) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .medium, design: .monospaced))
                .monospacedDigit()
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.vtDim)
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Recent Sessions

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !dataService.recentSessions.isEmpty {
                Text(L10n.s(.recent, lang))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.vtDim)
                    .tracking(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 32)

                List {
                    ForEach(dataService.recentSessions) { session in
                        NavigationLink {
                            SessionDetailView(session: session)
                        } label: {
                            sessionRow(session)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 32, bottom: 0, trailing: 32))
                        .listRowBackground(Color.clear)
                        .listRowSeparatorTint(.vtBorder)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                withAnimation {
                                    dataService.deleteSession(session)
                                }
                            } label: {
                                Label(L10n.s(.delete, lang), systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .scrollDisabled(true)
                .frame(minHeight: CGFloat(dataService.recentSessions.count) * 95)
            }
        }
    }

    private func sessionRow(_ session: SessionData) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(session.dateLabel(lang))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.vtText)

                    if let title = session.title, !title.isEmpty {
                        Text("· \(title)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.vtMuted)
                            .lineLimit(1)
                    }
                }

                Text("\(session.totalHands) \(L10n.s(.handsCount, lang)) · \(session.durationFormatted(lang))")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(.vtDim)

                // Table info
                Text(session.tableInfoLabel(lang))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.vtDim)
            }

            Spacer()

            HStack(spacing: 12) {
                if let bb = session.totalBBResult, bb != 0 {
                    Text(String(format: "%+.0f", bb))
                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                        .monospacedDigit()
                        .foregroundColor(bb > 0 ? .vtAccent : .vtRed)
                }

                Text("\(session.sessionVPIP)%")
                    .font(.system(size: 15, weight: .medium, design: .monospaced))
                    .monospacedDigit()
                    .foregroundColor(.vtMuted)
            }
        }
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
