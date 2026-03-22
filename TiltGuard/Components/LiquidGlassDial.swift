import SwiftUI

struct LiquidGlassDial: View {
    let vpipValue: Int
    let targetValue: Int
    let label: String
    let isBuilding: Bool
    var handsPlayed: Int = 0
    var handsRequired: Int = 10

    @State private var animatedProgress: CGFloat = 0
    @State private var appeared = false

    private let dialSize: CGFloat = 240
    private let ringWidth: CGFloat = 6

    private var progress: CGFloat {
        guard targetValue > 0 else { return 0 }
        return min(CGFloat(vpipValue) / CGFloat(max(targetValue, 1)), 1.5)
    }

    private var progressColor: Color {
        if vpipValue <= targetValue + 3 {
            return .vtAccent
        } else if vpipValue <= targetValue + 8 {
            return .vtAmber
        } else {
            return .vtRed
        }
    }

    var body: some View {
        ZStack {
            // Outer glow - layered for depth
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            progressColor.opacity(0.2),
                            progressColor.opacity(0.05),
                            .clear
                        ],
                        center: .center,
                        startRadius: dialSize * 0.3,
                        endRadius: dialSize * 0.7
                    )
                )
                .frame(width: dialSize + 100, height: dialSize + 100)
                .blur(radius: 20)

            // Glass dial body
            ZStack {
                // Base glass circle
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: dialSize, height: dialSize)

                // Glass overlay gradient (reflection)
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.12),
                                Color.white.opacity(0.02),
                                Color.clear,
                                Color.white.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: dialSize, height: dialSize)

                // Glass border
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.05),
                                Color.white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .frame(width: dialSize, height: dialSize)

                // Track ring (background)
                Circle()
                    .stroke(Color.white.opacity(0.06), lineWidth: ringWidth)
                    .frame(width: dialSize - 32, height: dialSize - 32)

                // Progress ring
                Circle()
                    .trim(from: 0, to: isBuilding ? CGFloat(handsPlayed) / CGFloat(handsRequired) * animatedProgress : min(animatedProgress * progress, 1.0))
                    .stroke(
                        AngularGradient(
                            colors: [
                                progressColor.opacity(0.3),
                                progressColor,
                                progressColor
                            ],
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                    )
                    .frame(width: dialSize - 32, height: dialSize - 32)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: progressColor.opacity(0.5), radius: 8, x: 0, y: 0)

                // Center content
                if isBuilding {
                    buildingContent
                } else {
                    vpipContent
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
                animatedProgress = 1.0
            }
            appeared = true
        }
    }

    // MARK: - VPIP Display

    private var vpipContent: some View {
        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(vpipValue)")
                    .font(.system(size: 64, weight: .thin, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .contentTransition(.numericText())

                Text("%")
                    .font(.system(size: 24, weight: .thin, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
            }

            Text(label.uppercased())
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundColor(.white.opacity(0.4))
                .tracking(3)
        }
    }

    // MARK: - Building Profile

    private var buildingContent: some View {
        VStack(spacing: 8) {
            Text("--")
                .font(.system(size: 48, weight: .thin, design: .rounded))
                .foregroundColor(.white.opacity(0.3))

            Text("BUILDING")
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundColor(.white.opacity(0.4))
                .tracking(3)

            Text("\(handsPlayed)/\(handsRequired)")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.3))
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        LiquidGlassDial(
            vpipValue: 22,
            targetValue: 25,
            label: "Current VPIP",
            isBuilding: false
        )
    }
}
