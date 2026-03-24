import SwiftUI
import SwiftData

struct SessionView: View {
    @Environment(DataService.self) private var dataService
    @Environment(LanguageManager.self) private var languageManager
    @State private var showVPIPInput = false
    @State private var showSummary = false
    @State private var endedSession: SessionData?
    @State private var shakeOffset: CGFloat = 0
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var emotionUndoVisible = false
    @State private var emotionUndoTimer: Timer?

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
            VPIPInputView()
        }
        .sheet(isPresented: $showSummary) {
            if let session = endedSession {
                SessionSummaryView(session: session)
            }
        }
        .overlay(alignment: .bottom) {
            if emotionUndoVisible {
                emotionUndoBanner
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 100)
            } else if showUndoConfirmation {
                undoConfirmationBanner
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 100)
            }
        }
        .offset(x: shakeOffset)
        .onChange(of: dataService.tiltPhase) { _, newPhase in
            if newPhase == .tilt {
                triggerShake()
            }
        }
        .onChange(of: dataService.currentHandRecords.count) { oldCount, newCount in
            if newCount > oldCount, let last = dataService.currentHandRecords.last, last.emotionSignal != nil {
                showEmotionUndo()
            }
        }
        .onAppear { startTimer() }
        .onDisappear { stopTimer(); emotionUndoTimer?.invalidate() }
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .stroke(Color.vtBorder, lineWidth: 1)
                        )
                        .contentShape(Rectangle())
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
                            dataService.recordFold()
                            hapticLight()
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

                            List {
                                ForEach(Array(recordedHands.reversed().enumerated()), id: \.element.id) { index, hand in
                                    handRecordRow(hand, index: recordedHands.count - index)
                                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                                        .listRowBackground(Color.clear)
                                        .listRowSeparatorTint(.vtBorder)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button(role: .destructive) {
                                                withAnimation {
                                                    dataService.deleteHandRecord(hand)
                                                }
                                            } label: {
                                                Label(L10n.s(.delete, languageManager.language), systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                            .scrollDisabled(true)
                            .frame(minHeight: CGFloat(recordedHands.count) * 64)
                        }
                        .padding(.top, 24)
                    }

                    Spacer().frame(height: 20)
                }
            }
            .scrollIndicators(.hidden)
        }
        .animation(.easeInOut(duration: 0.3), value: dataService.currentAlert != nil)
    }

    private func handRecordRow(_ hand: HandRecordData, index: Int) -> some View {
        HStack(spacing: 10) {
            Text("#\(index)")
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundColor(.vtMuted)
                .frame(width: 34, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(hand.handType ?? "VPIP")
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        .foregroundColor(.vtText)

                    if !hand.didVPIP {
                        Text("FOLD")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.vtMuted)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.vtSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    }
                }

                // Emotion signal label
                if let emotion = hand.emotionSignal {
                    Text(emotionDisplayLabel(emotion))
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(emotionDisplayColor(emotion))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(emotionDisplayColor(emotion).opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                }
            }

            Spacer()

            if hand.didVPIP {
                VStack(alignment: .trailing, spacing: 3) {
                    if hand.result == .win {
                        Text(L10n.s(.win, languageManager.language))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.vtText)
                    } else {
                        Text(L10n.s(.loss, languageManager.language))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.vtMuted)
                    }

                    if let bb = hand.bbResult {
                        Text(String(format: "%+.0f", bb))
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(bb >= 0 ? .vtText : .vtRed)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }

    private func emotionDisplayLabel(_ emotion: EmotionSignal) -> String {
        switch emotion {
        case .badBeat: return "Bad Beat"
        case .cooler: return "Cooler"
        case .tilt: return "Tilt"
        }
    }

    private func emotionDisplayColor(_ emotion: EmotionSignal) -> Color {
        switch emotion {
        case .badBeat: return .vtAmber
        case .cooler: return .vtMuted
        case .tilt: return .vtRed
        }
    }

    // MARK: - Stats Strip

    private var statsStrip: some View {
        HStack(spacing: 0) {
            if isWarmingUp {
                // Warm-up: just show hand count and lifetime
                stripCell(value: "\(dataService.sessionHands)", label: L10n.s(.hands, languageManager.language))

                stripCell(value: "\(dataService.lifetimeVPIP)%", label: L10n.s(.lifetime, languageManager.language))

                if let bb = dataService.activeSession?.totalBBResult, bb != 0 {
                    stripCell(
                        value: String(format: "%+.0f", bb),
                        label: "BB",
                        color: bb >= 0 ? .vtText : .vtRed
                    )
                } else {
                    stripCell(value: "—", label: "VPIP")
                }
            } else if showAbnormalMode && thirtyMinReliable {
                stripCell(value: "\(dataService.sessionVPIP)%", label: L10n.s(.sessionVPIP, languageManager.language))

                stripCell(value: "\(dataService.lifetimeVPIP)%", label: L10n.s(.lifetime, languageManager.language))

                stripCell(value: "\(dataService.sessionHands)", label: L10n.s(.hands, languageManager.language))
            } else {
                stripCell(value: thirtyMinReliable ? "\(dataService.thirtyMinVPIP)%" : "—", label: "30MIN")

                stripCell(value: "\(dataService.lifetimeVPIP)%", label: L10n.s(.lifetime, languageManager.language))

                if let bb = dataService.activeSession?.totalBBResult, bb != 0 {
                    stripCell(
                        value: String(format: "%+.0f", bb),
                        label: "BB",
                        color: bb >= 0 ? .vtText : .vtRed
                    )
                } else {
                    stripCell(value: "\(dataService.sessionHands)", label: L10n.s(.hands, languageManager.language))
                }
            }
        }
        .padding(.vertical, 14)
        .animation(.easeOut(duration: 0.3), value: dataService.sessionHands)
    }

    private func stripCell(value: String, label: String, color: Color = .vtText) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .medium, design: .monospaced))
                .monospacedDigit()
                .foregroundColor(color)
                .contentTransition(.numericText())

            Text(label)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.vtMuted)
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
    }

    private var statusColor: Color {
        switch dataService.currentStatus {
        case .normal: return .vtText
        case .warning: return .vtAmber
        case .danger: return .vtRed
        case .recovering: return .vtTeal
        }
    }

    private var showAbnormalMode: Bool {
        dataService.currentStatus != .normal && dataService.currentStatus != .recovering
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
        } else if dataService.tiltPhase == .tilt {
            tiltHero
        } else if dataService.tiltPhase == .recovering {
            recoveringHero
        } else if showAbnormalMode && thirtyMinReliable {
            abnormalHero
        } else {
            normalHero
        }
    }

    private var warmUpHero: some View {
        VStack(spacing: 12) {
            Text(L10n.s(.establishingBaseline, languageManager.language))
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.vtDim)
                .tracking(2)

            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.vtBorder, lineWidth: 2)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: CGFloat(dataService.sessionHands) / CGFloat(vpipDisplayThreshold))
                    .stroke(Color.vtText.opacity(0.6), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.3), value: dataService.sessionHands)

                VStack(spacing: 2) {
                    Text("\(dataService.sessionHands)")
                        .font(.system(size: 40, weight: .ultraLight, design: .monospaced))
                        .foregroundColor(.vtText)
                        .contentTransition(.numericText())

                    Text("/ \(vpipDisplayThreshold)")
                        .font(.system(size: 15, design: .monospaced))
                        .foregroundColor(.vtDim)
                }
            }

            let remaining = vpipDisplayThreshold - dataService.sessionHands
            Text("\(remaining) \(L10n.s(.moreToUnlockVPIP, languageManager.language))")
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.vtDim)
        }
    }

    private var tiltHero: some View {
        VStack(spacing: 12) {
            Text(L10n.s(.adjust, languageManager.language))
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.vtRed)
                .tracking(2)

            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text("\(dataService.sessionVPIP)")
                    .font(.system(size: 96, weight: .ultraLight, design: .monospaced))
                    .foregroundColor(.vtRed)
                    .contentTransition(.numericText())

                Text("%")
                    .font(.system(size: 32, weight: .ultraLight, design: .monospaced))
                    .foregroundColor(.vtRed.opacity(0.5))
            }

            Text(L10n.s(.tightenRange2, languageManager.language))
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
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

    private var recoveringHero: some View {
        VStack(spacing: 12) {
            Text(L10n.s(.recoveringH, languageManager.language))
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.vtTeal)
                .tracking(2)

            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text("\(dataService.sessionVPIP)")
                    .font(.system(size: 96, weight: .ultraLight, design: .monospaced))
                    .foregroundColor(.vtTeal)
                    .contentTransition(.numericText())

                Text("%")
                    .font(.system(size: 32, weight: .ultraLight, design: .monospaced))
                    .foregroundColor(.vtTeal.opacity(0.5))
            }

            Text(L10n.s(.recoveringD, languageManager.language))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.vtMuted)
                .multilineTextAlignment(.center)
        }
    }

    private var abnormalHero: some View {
        VStack(spacing: 8) {
            Text(L10n.s(.thirtyMinVPIP, languageManager.language))
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.vtMuted)
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
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(.vtMuted)
            }

            statusIndicator
                .padding(.top, 6)
        }
    }

    private var normalHero: some View {
        VStack(spacing: 8) {
            Text(L10n.s(.sessionVPIP, languageManager.language))
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.vtMuted)
                .tracking(2)

            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text("\(dataService.sessionVPIP)")
                    .font(.system(size: 96, weight: .ultraLight, design: .monospaced))
                    .contentTransition(.numericText())
                    .foregroundColor(.vtText)

                Text("%")
                    .font(.system(size: 32, weight: .ultraLight, design: .monospaced))
                    .foregroundColor(.vtMuted)
            }

            let diff = dataService.sessionVPIP - dataService.lifetimeVPIP
            if diff != 0 {
                Text(diff > 0 ? "↑\(diff)% \(L10n.s(.vsLifetime, languageManager.language))" : "↓\(abs(diff))% \(L10n.s(.vsLifetime, languageManager.language))")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(.vtMuted)
            } else {
                Text(L10n.s(.eqLifetime, languageManager.language))
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.vtMuted)
            }

            Text("\(L10n.s(.handNumber, languageManager.language)) #\(dataService.sessionHands)\(L10n.s(.handNumberSuffix, languageManager.language))")
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundColor(.vtMuted)
                .padding(.top, 4)
        }
    }

    private func buildCoachText(headline: String, detail: String, messageType: TiltCoachMessage.MessageType) -> AttributedString {
        var label = AttributedString(headline.uppercased())
        label.font = .system(size: 11, weight: .bold, design: .monospaced)
        switch messageType {
        case .danger: label.foregroundColor = .vtRed
        case .warning, .watch: label.foregroundColor = .vtAmber
        case .recovering: label.foregroundColor = .vtTeal
        }

        var separator = AttributedString(" · ")
        separator.font = .system(size: 11, design: .monospaced)
        separator.foregroundColor = .vtDim

        var body = AttributedString(detail)
        body.font = .system(size: 12)
        body.foregroundColor = .vtText

        return label + separator + body
    }

    // MARK: - Status Indicator

    @ViewBuilder
    private var statusIndicator: some View {
        let status = dataService.currentStatus

        switch status {
        case .normal:
            EmptyView()

        case .warning:
            Text(L10n.s(.watch, languageManager.language))
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(.vtAmber)
                .tracking(1.5)

        case .danger:
            Text(L10n.s(.adjust, languageManager.language))
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(.vtRed)
                .tracking(1.5)

        case .recovering:
            EmptyView()
        }
    }

    // MARK: - Behavior Analysis

    @ViewBuilder
    private var behaviorAnalysis: some View {
        if let msg = dataService.activeCoachMessage {
            Text(buildCoachText(headline: msg.headline, detail: msg.detail, messageType: msg.type))
                .font(.system(size: 12, weight: .regular))
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .frame(maxWidth: .infinity)
        } else {
            if let bb = dataService.activeSession?.totalBBResult, bb != 0 {
                let bbStr = bb > 0 ? "+\(Int(bb))" : "\(Int(bb))"
                Text(String(format: L10n.s(.sessionBB, languageManager.language), bbStr))
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(bb > 0 ? .vtText : .vtMuted)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Emotion Undo

    @State private var undoConfirmationText: String = ""

    private var emotionUndoBanner: some View {
        Button {
            undoLastEmotion()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 12, weight: .medium))
                Text(L10n.s(.emotionUndoLabel, languageManager.language))
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
            }
            .foregroundColor(.vtText)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.vtElevated)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.vtBorder, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }

    /// Banner shown briefly after undo confirming removal
    private var undoConfirmationBanner: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 12))
                .foregroundColor(.vtTeal)
            Text(undoConfirmationText)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.vtText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.vtElevated)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.vtBorder, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
    }

    @State private var showUndoConfirmation = false

    private func showEmotionUndo() {
        withAnimation(.easeOut(duration: 0.2)) { emotionUndoVisible = true }
        emotionUndoTimer?.invalidate()
        emotionUndoTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            DispatchQueue.main.async {
                withAnimation(.easeIn(duration: 0.2)) { self.emotionUndoVisible = false }
            }
        }
    }

    private func undoLastEmotion() {
        guard let last = dataService.currentHandRecords.last, last.emotionSignal != nil else { return }
        last.emotionSignal = nil

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Hide undo button, show confirmation
        withAnimation(.easeIn(duration: 0.2)) {
            emotionUndoVisible = false
            undoConfirmationText = L10n.s(.emotionUndoMessage, languageManager.language)
            showUndoConfirmation = true
        }
        emotionUndoTimer?.invalidate()

        // Auto-hide confirmation after 1.5s
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeIn(duration: 0.2)) { self.showUndoConfirmation = false }
        }

        // Re-check tilt phase after removing emotion
        dataService.checkTiltPhaseTransition()
    }

    // MARK: - No Session

    private var noSessionView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                // Shield icon
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 44, weight: .thin))
                    .foregroundColor(.vtDim)

                VStack(spacing: 10) {
                    Text(L10n.s(.liveEmptyTitle, languageManager.language))
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.vtText)

                    Text(L10n.s(.liveEmptyBody, languageManager.language))
                        .font(.system(size: 14))
                        .foregroundColor(.vtMuted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                // Feature list
                VStack(alignment: .leading, spacing: 14) {
                    featureRow(icon: "chart.bar.fill", text: L10n.s(.liveFeature1, languageManager.language))
                    featureRow(icon: "exclamationmark.shield.fill", text: L10n.s(.liveFeature2, languageManager.language))
                    featureRow(icon: "checkmark.message.fill", text: L10n.s(.liveFeature3, languageManager.language))
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 40)

            Spacer()

            // Subtle hint
            Text(L10n.s(.startFromHome, languageManager.language))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.vtDim)
                .padding(.bottom, 32)
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.vtMuted)
                .frame(width: 20)

            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.vtMuted)
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
