import SwiftUI

struct StrategyInsightCard: View {
    let strategy: PokerStrategy
    let currentVPIP: Int
    let lang: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title row
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.vtAccent)

                Text(L10n.s(.strategyInsightTitle, lang))
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
                    .tracking(1.5)

                Spacer()

                // Target badge
                Text("\(strategy.vpipTarget)%")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.vtAccent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.vtAccent.opacity(0.12))
                    .clipShape(Capsule())
            }

            // Description
            Text(strategy.description(lang))
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.white.opacity(0.55))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)

                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.05),
                            Color.white.opacity(0.03),
                            Color.white.opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        StrategyInsightCard(
            strategy: .balanced,
            currentVPIP: 22,
            lang: .english
        )
        .padding()
    }
}
