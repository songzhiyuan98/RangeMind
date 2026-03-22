import SwiftUI

enum PokerStrategy: CaseIterable {
    case tight, balanced, loose

    var vpipTarget: Int {
        switch self {
        case .tight: return 18
        case .balanced: return 24
        case .loose: return 32
        }
    }

    var icon: String {
        switch self {
        case .tight: return "shield.fill"
        case .balanced: return "circle.grid.cross.fill"
        case .loose: return "flame.fill"
        }
    }

    func label(_ lang: AppLanguage) -> String {
        switch self {
        case .tight: return L10n.s(.strategyTight, lang)
        case .balanced: return L10n.s(.strategyBalanced, lang)
        case .loose: return L10n.s(.strategyLoose, lang)
        }
    }

    func description(_ lang: AppLanguage) -> String {
        switch self {
        case .tight: return L10n.s(.strategyTightDesc, lang)
        case .balanced: return L10n.s(.strategyBalancedDesc, lang)
        case .loose: return L10n.s(.strategyLooseDesc, lang)
        }
    }
}

struct StrategyButton: View {
    let strategy: PokerStrategy
    let isSelected: Bool
    let lang: AppLanguage
    let action: () -> Void

    private let size: CGFloat = 72

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    // Glass circle
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: size, height: size)

                    // Glass gradient overlay
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(isSelected ? 0.18 : 0.08),
                                    Color.white.opacity(0.02)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: size, height: size)

                    // Selected glow
                    if isSelected {
                        Circle()
                            .fill(Color.vtAccent.opacity(0.15))
                            .frame(width: size, height: size)

                        Circle()
                            .stroke(Color.vtAccent.opacity(0.6), lineWidth: 1.5)
                            .frame(width: size, height: size)
                            .shadow(color: .vtAccent.opacity(0.4), radius: 8)
                    } else {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.2),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                            .frame(width: size, height: size)
                    }

                    // Icon
                    Image(systemName: strategy.icon)
                        .font(.system(size: 22, weight: .light))
                        .foregroundColor(isSelected ? .vtAccent : .white.opacity(0.5))
                        .shadow(color: isSelected ? .vtAccent.opacity(0.5) : .clear, radius: 6)
                }

                // Label
                Text(strategy.label(lang))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(isSelected ? .vtAccent : .white.opacity(0.4))
                    .tracking(1)

                // Target VPIP
                Text("\(strategy.vpipTarget)%")
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundColor(isSelected ? .white.opacity(0.6) : .white.opacity(0.25))
            }
        }
        .buttonStyle(GlassButtonStyle())
    }
}

struct GlassButtonStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HStack(spacing: 24) {
            StrategyButton(strategy: .tight, isSelected: false, lang: .english) {}
            StrategyButton(strategy: .balanced, isSelected: true, lang: .english) {}
            StrategyButton(strategy: .loose, isSelected: false, lang: .english) {}
        }
    }
}
