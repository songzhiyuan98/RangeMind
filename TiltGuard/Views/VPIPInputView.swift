import SwiftUI
import SwiftData

enum HandInputMode {
    case vpip
    case fold
}

struct VPIPInputView: View {
    @Environment(DataService.self) private var dataService
    @Environment(LanguageManager.self) private var languageManager
    @Environment(\.dismiss) private var dismiss

    var mode: HandInputMode = .vpip

    @State private var card1: String? = nil
    @State private var card2: String? = nil
    @State private var isSuited: Bool = false

    // Pro features (VPIP only)
    @State private var bbAmountText: String = ""
    @State private var showPositionGuide = false
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
                VStack(spacing: 20) {
                    Spacer().frame(height: 8)

                    // Title
                    Text(L10n.s(.yourHand, lang))
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.vtDim)
                        .tracking(3)

                    // Card preview
                    HStack(spacing: 12) {
                        CardSlot(rank: card1)
                        CardSlot(rank: card2)
                    }

                    // Rank selector
                    RankSelector(card1: $card1, card2: $card2)

                    // Suited selector
                    HStack(spacing: 10) {
                        SuitButton(title: L10n.s(.suited, lang), isSelected: isSuited, isDisabled: isPocketPair) {
                            isSuited = true
                        }
                        SuitButton(title: L10n.s(.offsuit, lang), isSelected: !isSuited, isDisabled: isPocketPair) {
                            isSuited = false
                        }
                    }
                    .padding(.horizontal, 20)
                    .opacity(isPocketPair ? 0.3 : 1.0)
                    .allowsHitTesting(!isPocketPair)

                    if mode == .vpip {
                        vpipControls
                    } else {
                        foldControls
                    }

                    // GTO preflop advice
                    if gtoAdviceEnabled, let hand = currentHandType {
                        gtoAdviceCard(hand: hand)
                    }

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
                    }
                }
            }
        }
    }

    // MARK: - VPIP Controls

    private var vpipControls: some View {
        VStack(spacing: 20) {
            // BB input
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.s(.bbAmount, lang))
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(.vtDim)
                    .tracking(2)
                    .padding(.horizontal, 20)

                HStack {
                    TextField("0", text: $bbAmountText)
                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                        .foregroundColor(.vtText)
                        .keyboardType(.decimalPad)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color.vtSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .stroke(Color.vtBorder, lineWidth: 1)
                        )

                    Text("BB")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(.vtDim)
                }
                .padding(.horizontal, 20)
            }

            Spacer().frame(height: 8)

            // Result buttons
            HStack(spacing: 12) {
                ActionButton(title: L10n.s(.win, lang), style: .primary) {
                    submitHand(result: .win)
                }
                .disabled(!canSubmit)
                .opacity(canSubmit ? 1.0 : 0.3)

                ActionButton(title: L10n.s(.loss, lang), style: .secondary) {
                    submitHand(result: .notWin)
                }
                .disabled(!canSubmit)
                .opacity(canSubmit ? 1.0 : 0.3)
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Fold Controls

    private var foldControls: some View {
        VStack(spacing: 12) {
            Spacer().frame(height: 8)

            if canSubmit {
                // Cards selected → show record fold as primary
                HStack(spacing: 12) {
                    ActionButton(title: L10n.s(.recordFold, lang), style: .primary) {
                        submitFold()
                    }

                    ActionButton(title: L10n.s(.quickFold, lang), style: .secondary) {
                        quickFold()
                    }
                }
                .padding(.horizontal, 20)
            } else {
                // No cards selected → quick fold is primary
                HStack(spacing: 12) {
                    ActionButton(title: L10n.s(.quickFold, lang), style: .primary) {
                        quickFold()
                    }

                    ActionButton(title: L10n.s(.recordFold, lang), style: .secondary) {
                        submitFold()
                    }
                    .disabled(true)
                    .opacity(0.3)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - GTO Advice

    private let positionOrder: [PokerPosition] = [.utg, .mp, .co, .btn, .sb, .bb]

    private func gtoAdviceCard(hand: String) -> some View {
        let openPositions = positionOrder.filter {
            GTORange.openRaiseRanges[$0]?.contains(hand) == true
        }
        let isWeak = GTORange.isObviouslyWeak(hand: hand)

        return VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                Text(L10n.s(.gtoAdvice, lang))
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(.vtDim)
                    .tracking(2)

                Spacer()

                Text(hand)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(.vtAccent)
            }
            .padding(.horizontal, 20)

            VStack(spacing: 0) {
                // Position grid — tappable
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showPositionGuide.toggle()
                    }
                } label: {
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            ForEach(positionOrder, id: \.self) { pos in
                                let inRange = GTORange.openRaiseRanges[pos]?.contains(hand) == true
                                VStack(spacing: 4) {
                                    Text(pos.rawValue)
                                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                                        .foregroundColor(inRange ? .vtText : .vtDim.opacity(0.4))

                                    Circle()
                                        .fill(inRange ? Color.vtAccent : Color.vtBorder)
                                        .frame(width: 8, height: 8)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)

                        // Tap hint
                        HStack(spacing: 4) {
                            Image(systemName: showPositionGuide ? "chevron.up" : "chevron.down")
                                .font(.system(size: 8))
                            Text(L10n.s(.tapForGuide, lang))
                                .font(.system(size: 9, design: .monospaced))
                        }
                        .foregroundColor(.vtDim.opacity(0.5))
                        .padding(.bottom, 8)
                    }
                }
                .buttonStyle(.plain)

                // Expanded position guide
                if showPositionGuide {
                    Rectangle()
                        .fill(Color.vtBorder)
                        .frame(height: 0.5)
                        .padding(.horizontal, 16)

                    positionGuideContent
                }

                Rectangle()
                    .fill(Color.vtBorder)
                    .frame(height: 0.5)
                    .padding(.horizontal, 16)

                // Strategy summary
                Text(gtoSummaryText(hand: hand, openPositions: openPositions, isWeak: isWeak))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.vtMuted)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.vtSurface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.vtBorder, lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
        .padding(.top, 16)
    }

    // MARK: - Position Guide

    @ViewBuilder
    private var positionGuideContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 6-max
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.s(.sixMax, lang))
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(.vtAccent)
                    .tracking(1)

                sixMaxDiagram

                VStack(alignment: .leading, spacing: 6) {
                    positionRow(name: "UTG", desc: L10n.s(.posUtgDesc, lang))
                    positionRow(name: "MP", desc: L10n.s(.posMpDesc, lang))
                    positionRow(name: "CO", desc: L10n.s(.posCoDesc, lang))
                    positionRow(name: "BTN", desc: L10n.s(.posBtnDesc, lang))
                    positionRow(name: "SB", desc: L10n.s(.posSbDesc, lang))
                    positionRow(name: "BB", desc: L10n.s(.posBbDesc, lang))
                }
            }

            Rectangle()
                .fill(Color.vtBorder)
                .frame(height: 0.5)

            // 9-max
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.s(.nineMax, lang))
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(.vtAccent)
                    .tracking(1)

                nineMaxDiagram

                VStack(alignment: .leading, spacing: 6) {
                    positionRow(name: "UTG", desc: L10n.s(.posUtgDesc, lang))
                    positionRow(name: "UTG+1", desc: L10n.s(.posUtg1Desc, lang))
                    positionRow(name: "UTG+2", desc: L10n.s(.posUtg2Desc, lang))
                    positionRow(name: "LJ", desc: L10n.s(.posLjDesc, lang))
                    positionRow(name: "HJ", desc: L10n.s(.posHjDesc, lang))
                    positionRow(name: "CO", desc: L10n.s(.posCoDesc, lang))
                    positionRow(name: "BTN", desc: L10n.s(.posBtnDesc, lang))
                    positionRow(name: "SB", desc: L10n.s(.posSbDesc, lang))
                    positionRow(name: "BB", desc: L10n.s(.posBbDesc, lang))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private func positionRow(name: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(name)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundColor(.vtText)
                .frame(width: 40, alignment: .leading)

            Text(desc)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.vtDim)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // 6-max visual diagram
    private var sixMaxDiagram: some View {
        let seats: [(String, CGFloat, CGFloat)] = [
            ("UTG", 0.15, 0.15),
            ("MP",  0.85, 0.15),
            ("CO",  0.95, 0.5),
            ("BTN", 0.85, 0.85),
            ("SB",  0.15, 0.85),
            ("BB",  0.05, 0.5),
        ]
        return tableDiagram(seats: seats)
    }

    // 9-max visual diagram
    private var nineMaxDiagram: some View {
        let seats: [(String, CGFloat, CGFloat)] = [
            ("UTG",   0.1,  0.15),
            ("UTG+1", 0.35, 0.05),
            ("UTG+2", 0.65, 0.05),
            ("LJ",    0.9,  0.15),
            ("HJ",    0.97, 0.45),
            ("CO",    0.9,  0.75),
            ("BTN",   0.65, 0.9),
            ("SB",    0.35, 0.9),
            ("BB",    0.05, 0.6),
        ]
        return tableDiagram(seats: seats)
    }

    private func tableDiagram(seats: [(String, CGFloat, CGFloat)]) -> some View {
        ZStack {
            // Table
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color.vtSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color.vtBorder, lineWidth: 1)
                )

            // Seats
            GeometryReader { geo in
                ForEach(Array(seats.enumerated()), id: \.offset) { _, seat in
                    let x = seat.1 * geo.size.width
                    let y = seat.2 * geo.size.height
                    Text(seat.0)
                        .font(.system(size: 8, weight: .medium, design: .monospaced))
                        .foregroundColor(.vtText)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .background(Color.vtBlack)
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .stroke(Color.vtAccent.opacity(0.3), lineWidth: 0.5)
                        )
                        .position(x: x, y: y)
                }
            }
        }
        .frame(height: 100)
        .padding(.horizontal, 8)
    }

    private func gtoSummaryText(hand: String, openPositions: [PokerPosition], isWeak: Bool) -> String {
        if isWeak {
            return L10n.s(.gtoFoldPre, lang)
        }

        if openPositions.isEmpty {
            if GTORange.callingRanges[.bb]?.contains(hand) == true {
                return lang == .english
                    ? "Not a standard open — can defend from BB vs raise."
                    : "不建议主动开池 — 可在 BB 位跟注防守。"
            }
            return L10n.s(.gtoFoldPre, lang)
        }

        let premiums: Set<String> = ["AA", "KK", "QQ", "AKs", "AKo"]
        if premiums.contains(hand) {
            return L10n.s(.gtoPremium, lang)
        }

        let hasUTG = openPositions.contains(.utg)
        let hasMP = openPositions.contains(.mp)
        let hasCO = openPositions.contains(.co)

        if hasUTG {
            return L10n.s(.gtoAllPositions, lang)
        } else if hasMP {
            return L10n.s(.gtoMidLate, lang)
        } else if hasCO {
            return L10n.s(.gtoLateOnly, lang)
        } else {
            return L10n.s(.gtoBtnOnly, lang)
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
            bbResult: finalBBResult,
            position: nil,
            actionType: nil
        )

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(result == .win ? .success : .warning)

        dismiss()
    }

    private func submitFold() {
        guard let c1 = card1, let c2 = card2 else { return }

        dataService.recordFold(
            card1: c1,
            card2: c2,
            isSuited: isPocketPair ? nil : isSuited
        )

        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        dismiss()
    }

    private func quickFold() {
        dataService.recordFold()

        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

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
                .frame(width: 56, height: 76)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(rank != nil ? Color.vtAccent.opacity(0.5) : Color.vtBorder, lineWidth: 1)
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

// MARK: - Suit Button

struct SuitButton: View {
    let title: String
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(isSelected ? .vtBlack : .vtMuted)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(isSelected ? Color.vtAccent : Color.vtSurface)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(isSelected ? Color.vtAccent : Color.vtBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

#Preview {
    VPIPInputView(mode: .vpip)
        .environment(DataService(modelContext: PreviewContainer.shared.mainContext))
        .environment(LanguageManager())
        .preferredColorScheme(.dark)
}
