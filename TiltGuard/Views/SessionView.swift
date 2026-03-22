import SwiftUI
import SwiftData

struct SessionView: View {
    @Environment(DataService.self) private var dataService
    @Environment(LanguageManager.self) private var languageManager
    @State private var showVPIPInput = false
    @State private var showFoldInput = false
    @State private var showSummary = false
    @State private var endedSession: SessionData?
    @State private var shakeOffset: CGFloat = 0
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            Color.vtBlack.ignoresSafeArea()

            if dataService.hasActiveSession {
                activeSessionView
            } else {
                noSessionView
            }
        }
        .sheet(isPresented: $showVPIPInput) {
            VPIPInputView(mode: .vpip)
        }
        .sheet(isPresented: $showFoldInput) {
            VPIPInputView(mode: .fold)
        }
        .sheet(isPresented: $showSummary) {
            if let session = endedSession {
                SessionSummaryView(session: session)
            }
        }
        .offset(x: shakeOffset)
        .onChange(of: dataService.currentStatus) { _, newStatus in
            if newStatus == .danger {
                triggerShake()
            }
        }
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
    }

    // MARK: - Timer

    private func startTimer() {
        guard let startTime = dataService.activeSession?.startTime else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                self.elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private var timerText: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    private func triggerShake() {
        withAnimation(.easeInOut(duration: 0.1).repeatCount(6, autoreverses: true)) {
            shakeOffset = 3
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            shakeOffset = 0
        }
    }

    // MARK: - Active Session

    private var activeSessionView: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Text(timerText)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundColor(.vtMuted)

                Spacer()

                Button {
                    if let session = dataService.endSession() {
                        endedSession = session
                        showSummary = true
                    }
                    stopTimer()
                } label: {
                    Text(L10n.s(.end, languageManager.language))
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(.vtDim)
                        .tracking(1)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .stroke(Color.vtBorder, lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            ScrollView {
                VStack(spacing: 0) {
                    // Guest mode indicator
                    if dataService.isGuestMode {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.vtAmber)
                                .frame(width: 4, height: 4)
                            Text(L10n.s(.guestSession, languageManager.language))
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.vtDim)
                            Text("·")
                                .foregroundColor(.vtDim)
                            Text(L10n.s(.guestDataNotSaved, languageManager.language))
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.vtDim)
                        }
                        .padding(.top, 8)
                    }

                    // Hero VPIP
                    heroVPIPSection
                        .padding(.top, dataService.isGuestMode ? 16 : 28)

                    Spacer().frame(height: 20)

                    // Stats strip
                    statsStrip
                        .padding(.horizontal, 20)

                    // Behavior warnings
                    behaviorAnalysis
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    Spacer().frame(height: 20)

                    // Action buttons
                    HStack(spacing: 12) {
                        ActionButton(title: L10n.s(.fold, languageManager.language), style: .secondary) {
                            showFoldInput = true
                        }

                        ActionButton(title: L10n.s(.vpip, languageManager.language), style: .primary) {
                            showVPIPInput = true
                        }
                    }
                    .padding(.horizontal, 20)

                    // Hand records (VPIP + recorded folds)
                    let recordedHands = dataService.currentHandRecords.filter { $0.didVPIP || $0.handType != nil }
                    if !recordedHands.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("\(L10n.s(.entries, languageManager.language)) (\(recordedHands.count))")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.vtDim)
                                .tracking(2)
                                .padding(.horizontal, 20)

                            VStack(spacing: 0) {
                                ForEach(Array(recordedHands.reversed().enumerated()), id: \.element.id) { index, hand in
                                    handRecordRow(hand, index: recordedHands.count - index)
                                        .contentShape(Rectangle())
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                withAnimation {
                                                    dataService.deleteHandRecord(hand)
                                                }
                                            } label: {
                                                Label(L10n.s(.delete, languageManager.language), systemImage: "trash")
                                            }
                                        }

                                    if index < recordedHands.count - 1 {
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
                        .padding(.top, 24)
                    }

                    Spacer().frame(height: 120)
                }
            }
            .scrollIndicators(.hidden)
        }
        .animation(.easeInOut(duration: 0.3), value: dataService.currentAlert != nil)
    }

    private func handRecordRow(_ hand: HandRecordData, index: Int) -> some View {
        HStack(spacing: 10) {
            Text("#\(index)")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.vtDim)
                .frame(width: 32, alignment: .leading)

            HStack(spacing: 6) {
                Text(hand.handType ?? "VPIP")
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    .foregroundColor(.vtText)

                if !hand.didVPIP {
                    Text("FOLD")
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundColor(.vtDim)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.vtBorder.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                }
            }

            Spacer()

            if hand.didVPIP {
                VStack(alignment: .trailing, spacing: 3) {
                    if hand.result == .win {
                        Text(L10n.s(.win, languageManager.language))
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.vtAccent)
                    } else {
                        Text(L10n.s(.loss, languageManager.language))
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.vtDim)
                    }

                    if let bb = hand.bbResult {
                        Text(String(format: "%+.0f", bb))
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(bb >= 0 ? .vtAccent : .vtRed)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Stats Strip

    private var statsStrip: some View {
        HStack(spacing: 0) {
            if isWarmingUp {
                // Warm-up: just show hand count and lifetime
                stripCell(value: "\(dataService.sessionHands)", label: L10n.s(.hands, languageManager.language))
                stripDivider
                stripCell(value: "\(dataService.lifetimeVPIP)%", label: L10n.s(.lifetime, languageManager.language))
                stripDivider
                if let bb = dataService.activeSession?.totalBBResult, bb != 0 {
                    stripCell(
                        value: String(format: "%+.0f", bb),
                        label: "BB",
                        color: bb >= 0 ? .vtAccent : .vtRed
                    )
                } else {
                    stripCell(value: "—", label: "VPIP")
                }
            } else if showAbnormalMode && thirtyMinReliable {
                stripCell(value: "\(dataService.sessionVPIP)%", label: L10n.s(.sessionVPIP, languageManager.language))
                stripDivider
                stripCell(value: "\(dataService.lifetimeVPIP)%", label: L10n.s(.lifetime, languageManager.language))
                stripDivider
                stripCell(value: "\(dataService.sessionHands)", label: L10n.s(.hands, languageManager.language))
            } else {
                stripCell(value: thirtyMinReliable ? "\(dataService.thirtyMinVPIP)%" : "—", label: "30MIN")
                stripDivider
                stripCell(value: "\(dataService.lifetimeVPIP)%", label: L10n.s(.lifetime, languageManager.language))
                stripDivider
                if let bb = dataService.activeSession?.totalBBResult, bb != 0 {
                    stripCell(
                        value: String(format: "%+.0f", bb),
                        label: "BB",
                        color: bb >= 0 ? .vtAccent : .vtRed
                    )
                } else {
                    stripCell(value: "\(dataService.sessionHands)", label: L10n.s(.hands, languageManager.language))
                }
            }
        }
        .padding(.vertical, 14)
        .background(Color.vtSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(statusBorderColor, lineWidth: statusBorderWidth)
        )
        .animation(.easeOut(duration: 0.3), value: dataService.sessionHands)
    }

    private var statusBorderColor: Color {
        switch dataService.currentStatus {
        case .normal: return .vtBorder
        case .warning: return .vtAmber.opacity(0.4)
        case .danger: return .vtRed.opacity(0.5)
        }
    }

    private var statusBorderWidth: CGFloat {
        dataService.currentStatus == .normal ? 1 : 1.5
    }

    private func stripCell(value: String, label: String, color: Color = .vtText) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 20, weight: .medium, design: .monospaced))
                .monospacedDigit()
                .foregroundColor(color)
                .contentTransition(.numericText())

            Text(label)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(.vtDim)
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
    }

    private var stripDivider: some View {
        Rectangle()
            .fill(Color.vtBorder)
            .frame(width: 1, height: 28)
    }

    private var statusColor: Color {
        switch dataService.currentStatus {
        case .normal: return .vtText
        case .warning: return .vtAmber
        case .danger: return .vtRed
        }
    }

    private var showAbnormalMode: Bool {
        dataService.currentStatus != .normal
    }

    // MARK: - Sample thresholds

    private let vpipDisplayThreshold = 10
    private let thirtyMinMinSample = 8

    private var isWarmingUp: Bool {
        dataService.sessionHands < vpipDisplayThreshold
    }

    private var thirtyMinReliable: Bool {
        dataService.thirtyMinHandCount >= thirtyMinMinSample
    }

    // MARK: - Hero VPIP

    @ViewBuilder
    private var heroVPIPSection: some View {
        if isWarmingUp {
            warmUpHero
        } else if dataService.tiltPhase == .cooldown {
            cooldownHero
        } else if dataService.tiltPhase == .observing {
            observingHero
        } else if showAbnormalMode && thirtyMinReliable {
            abnormalHero
        } else {
            normalHero
        }
    }

    private var warmUpHero: some View {
        VStack(spacing: 12) {
            Text(L10n.s(.establishingBaseline, languageManager.language))
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.vtDim)
                .tracking(2)

            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.vtBorder, lineWidth: 2)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: CGFloat(dataService.sessionHands) / CGFloat(vpipDisplayThreshold))
                    .stroke(Color.vtAccent.opacity(0.6), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.3), value: dataService.sessionHands)

                VStack(spacing: 2) {
                    Text("\(dataService.sessionHands)")
                        .font(.system(size: 32, weight: .ultraLight, design: .monospaced))
                        .foregroundColor(.vtText)
                        .contentTransition(.numericText())

                    Text("/ \(vpipDisplayThreshold)")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.vtDim)
                }
            }

            let remaining = vpipDisplayThreshold - dataService.sessionHands
            Text("\(remaining) \(L10n.s(.moreToUnlockVPIP, languageManager.language))")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.vtDim)
        }
    }

    private var cooldownHero: some View {
        VStack(spacing: 12) {
            Text(L10n.s(.cooldownMode, languageManager.language))
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.vtRed)
                .tracking(2)

            // Countdown ring
            ZStack {
                Circle()
                    .stroke(Color.vtBorder, lineWidth: 2)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: dataService.cooldownTotal > 0 ? CGFloat(dataService.cooldownRemaining) / CGFloat(dataService.cooldownTotal) : 0)
                    .stroke(Color.vtRed.opacity(0.7), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.3), value: dataService.cooldownRemaining)

                VStack(spacing: 2) {
                    Text("\(dataService.cooldownRemaining)")
                        .font(.system(size: 32, weight: .ultraLight, design: .monospaced))
                        .foregroundColor(.vtRed)
                        .contentTransition(.numericText())

                    Text("/ \(dataService.cooldownTotal)")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.vtDim)
                }
            }

            Text(String(format: L10n.s(.cooldownSuggestion, languageManager.language), dataService.cooldownTotal))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.vtDim)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Text(L10n.s(.tightenRange2, languageManager.language))
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundColor(.vtRed)
                .tracking(1)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(Color.vtRed.opacity(0.3), lineWidth: 1)
                )
        }
    }

    private var observingHero: some View {
        VStack(spacing: 12) {
            Text(L10n.s(.cooldownObserving, languageManager.language))
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.vtAmber)
                .tracking(2)

            // Progress ring
            let handsSince = dataService.sessionHands - dataService.phaseStartHandCount
            let windowSize = 5

            ZStack {
                Circle()
                    .stroke(Color.vtBorder, lineWidth: 2)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: CGFloat(handsSince) / CGFloat(windowSize))
                    .stroke(Color.vtAmber.opacity(0.6), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.3), value: handsSince)

                VStack(spacing: 2) {
                    Text("\(handsSince)")
                        .font(.system(size: 32, weight: .ultraLight, design: .monospaced))
                        .foregroundColor(.vtAmber)
                        .contentTransition(.numericText())

                    Text("/ \(windowSize)")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.vtDim)
                }
            }

            Text(String(format: L10n.s(.cooldownObservingDesc, languageManager.language), windowSize))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.vtDim)

            // Still show session VPIP below
            Text("\(dataService.sessionVPIP)% VPIP")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.vtDim)
                .padding(.top, 4)
        }
    }

    private var abnormalHero: some View {
        VStack(spacing: 6) {
            Text(L10n.s(.thirtyMinVPIP, languageManager.language))
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.vtDim)
                .tracking(2)

            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text("\(dataService.thirtyMinVPIP)")
                    .font(.system(size: 96, weight: .ultraLight, design: .monospaced))
                    .foregroundColor(statusColor)
                    .contentTransition(.numericText())

                Text("%")
                    .font(.system(size: 32, weight: .ultraLight, design: .monospaced))
                    .foregroundColor(statusColor.opacity(0.5))
            }

            let diff = dataService.thirtyMinVPIP - dataService.sessionVPIP
            if diff != 0 {
                Text(diff > 0 ? "↑\(diff)% \(L10n.s(.vsSession, languageManager.language))" : "↓\(abs(diff))% \(L10n.s(.vsSession, languageManager.language))")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.vtDim)
            }

            statusIndicator
                .padding(.top, 6)
        }
    }

    private var normalHero: some View {
        VStack(spacing: 6) {
            Text(L10n.s(.sessionVPIP, languageManager.language))
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.vtDim)
                .tracking(2)

            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text("\(dataService.sessionVPIP)")
                    .font(.system(size: 96, weight: .ultraLight, design: .monospaced))
                    .contentTransition(.numericText())
                    .foregroundColor(.vtText)

                Text("%")
                    .font(.system(size: 32, weight: .ultraLight, design: .monospaced))
                    .foregroundColor(.vtDim)
            }

            let diff = dataService.sessionVPIP - dataService.lifetimeVPIP
            if diff != 0 {
                Text(diff > 0 ? "↑\(diff)% \(L10n.s(.vsLifetime, languageManager.language))" : "↓\(abs(diff))% \(L10n.s(.vsLifetime, languageManager.language))")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.vtDim)
            } else {
                Text(L10n.s(.eqLifetime, languageManager.language))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.vtDim)
            }

            Text("\(L10n.s(.handNumber, languageManager.language)) #\(dataService.sessionHands)\(L10n.s(.handNumberSuffix, languageManager.language))")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.vtDim)
                .padding(.top, 4)
        }
    }

    // MARK: - Status Indicator

    @ViewBuilder
    private var statusIndicator: some View {
        let status = dataService.currentStatus

        switch status {
        case .normal:
            EmptyView()

        case .warning, .danger:
            HStack(spacing: 6) {
                Circle()
                    .fill(status == .danger ? Color.vtRed : Color.vtAmber)
                    .frame(width: 5, height: 5)
                Text(status == .danger ? L10n.s(.adjust, languageManager.language) : L10n.s(.watch, languageManager.language))
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(.vtMuted)
                    .tracking(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .overlay(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(Color.vtBorder, lineWidth: 1)
            )
        }
    }

    // MARK: - Behavior Analysis

    @ViewBuilder
    private var behaviorAnalysis: some View {
        if let msg = dataService.activeCoachMessage {
            VStack(alignment: .leading, spacing: 4) {
                Text(msg.headline)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(msg.type == .danger ? .vtRed : .vtAmber)

                Text(msg.detail)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.vtDim)
                    .lineSpacing(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background((msg.type == .danger ? Color.vtRed : Color.vtAmber).opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke((msg.type == .danger ? Color.vtRed : Color.vtAmber).opacity(0.2), lineWidth: 1)
            )
        } else {
            if let bb = dataService.activeSession?.totalBBResult, bb != 0 {
                let bbStr = bb > 0 ? "+\(Int(bb))" : "\(Int(bb))"
                Text(String(format: L10n.s(.sessionBB, languageManager.language), bbStr))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(bb > 0 ? .vtAccent : .vtDim)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: - No Session

    private var noSessionView: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("♠")
                .font(.system(size: 48))
                .foregroundColor(.vtDim)

            Text(L10n.s(.noActiveSession, languageManager.language))
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.vtMuted)

            Text(L10n.s(.startFromHome, languageManager.language))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.vtDim)

            Spacer()
        }
    }

    private func hapticLight() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    private func hapticMedium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

#Preview {
    SessionView()
        .environment(DataService(modelContext: PreviewContainer.shared.mainContext))
        .environment(LanguageManager())
        .preferredColorScheme(.dark)
}
