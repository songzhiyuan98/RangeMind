import SwiftUI
import SwiftData

struct VPIPInputView: View {
    @Environment(DataService.self) private var dataService
    @Environment(LanguageManager.self) private var languageManager
    @Environment(\.dismiss) private var dismiss

    @State private var card1: String? = nil
    @State private var card2: String? = nil
    @State private var isSuited: Bool = false

    // Pro features (VPIP only)
    @State private var bbAmountText: String = ""
    @State private var selectedEmotion: EmotionSignal? = nil
    @State private var showEmotionConfirm: Bool = false
    @State private var pendingEmotion: EmotionSignal? = nil
    @AppStorage("vt_gto_advice_enabled") private var gtoAdviceEnabled = true

    private var lang: AppLanguage { languageManager.language }

    private var isPocketPair: Bool {
        card1 == card2 && card1 != nil
    }

    private var canSubmit: Bool {
        card1 != nil && card2 != nil
    }

    private var bbAmount: Double? {
        guard !bbAmountText.isEmpty else { return nil }
        return Double(bbAmountText)
    }

    private var currentHandType: String? {
        guard let c1 = card1, let c2 = card2 else { return nil }
        let ranks = ["A", "K", "Q", "J", "T", "9", "8", "7", "6", "5", "4", "3", "2"]
        let sorted = [c1, c2].sorted { ranks.firstIndex(of: $0)! < ranks.firstIndex(of: $1)! }

        if c1 == c2 {
            return "\(c1)\(c2)"
        }
        let suffix = isSuited ? "s" : "o"
        return "\(sorted[0])\(sorted[1])\(suffix)"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Hand preview + hand type
                    handPreview
                        .padding(.top, 20)
                        .padding(.bottom, 16)

                    // Rank selector
                    RankSelector(card1: $card1, card2: $card2)
                        .padding(.bottom, 12)

                    // Suited toggle
                    suitedToggle
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)

                    // GTO advice + percentile (directly after card selection)
                    if let hand = currentHandType {
                        handInfoBar(hand: hand)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                    }

                    // Divider
                    Rectangle()
                        .fill(Color.vtBorder)
                        .frame(height: 0.5)
                        .padding(.horizontal, 20)

                    vpipControls
                        .padding(.top, 16)

                    Spacer().frame(height: 20)
                }
            }
            .scrollIndicators(.hidden)
            .background(Color.vtBlack.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.vtDim)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                }
            }
        }
    }

    // MARK: - Hand Preview

    private var handPreview: some View {
        VStack(spacing: 10) {
            // Card slots
            HStack(spacing: 10) {
                CardSlot(rank: card1)
                CardSlot(rank: card2)
            }

            // Hand type label
            if let ht = currentHandType {
                Text(ht)
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundColor(.vtText)
                    .tracking(1)
            } else {
                Text(L10n.s(.yourHand, lang))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.vtDim)
                    .tracking(2)
            }
        }
    }

    // MARK: - Suited Toggle

    private var suitedToggle: some View {
        HStack(spacing: 6) {
            pillButton(L10n.s(.suited, lang), selected: isSuited) {
                isSuited = true
            }
            pillButton(L10n.s(.offsuit, lang), selected: !isSuited) {
                isSuited = false
            }
        }
        .opacity(isPocketPair ? 0.25 : 1.0)
        .allowsHitTesting(!isPocketPair)
    }

    private func pillButton(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(selected ? .vtBlack : .vtMuted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(selected ? Color.vtText : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(selected ? Color.clear : Color.vtBorder, lineWidth: 1)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - VPIP Controls

    private var vpipControls: some View {
        VStack(spacing: 0) {
            // Optional hint
            Text(L10n.s(.vpipOptionalHint, lang))
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.vtDim)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

            // BB input row
            HStack(spacing: 12) {
                Text("BB")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.vtDim)
                    .tracking(1)
                    .frame(width: 28, alignment: .leading)

                TextField("0", text: $bbAmountText)
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundColor(.vtText)
                    .keyboardType(.decimalPad)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.vtSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(Color.vtBorder, lineWidth: 1)
                    )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            // Divider between BB and emotion
            Rectangle()
                .fill(Color.vtBorder)
                .frame(height: 0.5)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

            // Emotion hint
            Text(L10n.s(.emotionHint, lang))
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(.vtDim)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

            // Emotion signal row with strength labels
            HStack(spacing: 6) {
                ForEach(EmotionSignal.allCases) { emotion in
                    let isActive = selectedEmotion == emotion
                    Button {
                        if isActive {
                            withAnimation(.easeOut(duration: 0.12)) {
                                selectedEmotion = nil
                            }
                        } else {
                            pendingEmotion = emotion
                            showEmotionConfirm = true
                        }
                    } label: {
                        VStack(spacing: 3) {
                            Text(emotionLabel(emotion))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(isActive ? .vtBlack : .vtMuted)
                            Text(emotionStrengthLabel(emotion))
                                .font(.system(size: 9, weight: .regular))
                                .foregroundColor(isActive ? .vtBlack.opacity(0.7) : .vtDim)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(isActive ? emotionAccent(emotion) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(isActive ? Color.clear : Color.vtBorder, lineWidth: 1)
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            .alert(emotionConfirmTitle, isPresented: $showEmotionConfirm) {
                Button(L10n.s(.emotionConfirmCancel, lang), role: .cancel) {
                    pendingEmotion = nil
                }
                Button(L10n.s(.emotionConfirmOK, lang)) {
                    if let emotion = pendingEmotion {
                        withAnimation(.easeOut(duration: 0.12)) {
                            selectedEmotion = emotion
                        }
                    }
                    pendingEmotion = nil
                }
            } message: {
                Text(emotionConfirmBody)
            }

            // Result buttons
            HStack(spacing: 10) {
                resultButton(L10n.s(.win, lang), isWin: true) {
                    submitHand(result: .win)
                }

                resultButton(L10n.s(.loss, lang), isWin: false) {
                    submitHand(result: .notWin)
                }
            }
            .padding(.horizontal, 20)
            .opacity(canSubmit ? 1.0 : 0.25)
            .allowsHitTesting(canSubmit)
        }
    }

    private func resultButton(_ title: String, isWin: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                .tracking(1)
                .foregroundColor(isWin ? .vtBlack : .vtMuted)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(isWin ? Color.vtText : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(isWin ? Color.clear : Color.vtBorder, lineWidth: 1)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Hand Info Bar (GTO + Percentile, inline)

    private let positionOrder: [PokerPosition] = [.utg, .mp, .co, .btn, .sb, .bb]

    /// Compact info bar shown directly after card selection:
    /// [Top 4.5%] [GTO summary] [position dots] [▾]
    private func handInfoBar(hand: String) -> some View {
        let pct = HandPercentile.percentile(for: hand)
        let openPositions = positionOrder.filter {
            GTORange.openRaiseRanges[$0]?.contains(hand) == true
        }
        let isWeak = GTORange.isObviouslyWeak(hand: hand)
        let summary = gtoSummaryShort(hand: hand, openPositions: openPositions, isWeak: isWeak)

        return HStack(spacing: 8) {
            // Percentile badge
            Text(String(format: "Top %.1f%%", pct))
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(pct <= 15 ? .vtText : pct <= 40 ? .vtMuted : .vtDim)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.vtSurface)
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(Color.vtBorder, lineWidth: 1)
                )

            Text(summary)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.vtMuted)
                .lineLimit(1)

            Spacer()
        }
    }

    /// Short GTO summary for inline display
    private func gtoSummaryShort(hand: String, openPositions: [PokerPosition], isWeak: Bool) -> String {
        if isWeak { return L10n.s(.gtoFoldPre, lang) }
        if openPositions.isEmpty { return L10n.s(.gtoFoldPre, lang) }

        let premiums: Set<String> = ["AA", "KK", "QQ", "AKs", "AKo"]
        if premiums.contains(hand) { return L10n.s(.gtoPremium, lang) }

        if openPositions.contains(.utg) { return L10n.s(.gtoAllPositions, lang) }
        if openPositions.contains(.mp) { return L10n.s(.gtoMidLate, lang) }
        if openPositions.contains(.co) { return L10n.s(.gtoLateOnly, lang) }
        return L10n.s(.gtoBtnOnly, lang)
    }

    // MARK: - Helpers

    private func emotionLabel(_ emotion: EmotionSignal) -> String {
        switch emotion {
        case .badBeat: return L10n.s(.emotionBadBeat, lang)
        case .cooler: return L10n.s(.emotionCooler, lang)
        case .tilt: return L10n.s(.emotionTilt, lang)
        }
    }

    private var emotionConfirmTitle: String {
        guard let emotion = pendingEmotion else { return "" }
        switch emotion {
        case .badBeat: return L10n.s(.badBeatConfirmTitle, lang)
        case .cooler: return L10n.s(.coolerConfirmTitle, lang)
        case .tilt: return L10n.s(.tiltConfirmTitle, lang)
        }
    }

    private var emotionConfirmBody: String {
        guard let emotion = pendingEmotion else { return "" }
        switch emotion {
        case .badBeat: return L10n.s(.badBeatConfirmBody, lang)
        case .cooler: return L10n.s(.coolerConfirmBody, lang)
        case .tilt: return L10n.s(.tiltConfirmBody, lang)
        }
    }

    private func emotionStrengthLabel(_ emotion: EmotionSignal) -> String {
        switch emotion {
        case .badBeat: return L10n.s(.emotionMildSignal, lang)
        case .cooler: return L10n.s(.emotionModerateSignal, lang)
        case .tilt: return L10n.s(.emotionStrongSignal, lang)
        }
    }

    private func emotionAccent(_ emotion: EmotionSignal) -> Color {
        switch emotion {
        case .badBeat: return .vtAmber
        case .cooler: return .vtMuted
        case .tilt: return .vtRed
        }
    }

    // MARK: - Actions

    private func submitHand(result: HandResult) {
        guard let c1 = card1, let c2 = card2 else { return }

        var finalBBResult: Double? = nil
        if let amount = bbAmount {
            finalBBResult = result == .win ? abs(amount) : -abs(amount)
        }

        dataService.recordVPIP(
            card1: c1,
            card2: c2,
            isSuited: isPocketPair ? nil : isSuited,
            result: result,
            emotionSignal: selectedEmotion,
            bbResult: finalBBResult,
            position: nil,
            actionType: nil
        )

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(result == .win ? .success : .warning)

        dismiss()
    }

}

// MARK: - Card Slot

struct CardSlot: View {
    let rank: String?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.vtSurface)
                .frame(width: 56, height: 74)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(rank != nil ? Color.vtText.opacity(0.4) : Color.vtBorder, lineWidth: 1)
                )

            if let rank = rank {
                Text(rank)
                    .font(.system(size: 28, weight: .medium, design: .monospaced))
                    .foregroundColor(.vtText)
            } else {
                Text("?")
                    .font(.system(size: 28, weight: .ultraLight, design: .monospaced))
                    .foregroundColor(.vtDim)
            }
        }
    }
}

#Preview {
    VPIPInputView()
        .environment(DataService(modelContext: PreviewContainer.shared.mainContext))
        .environment(LanguageManager())
        .preferredColorScheme(.dark)
}
