import SwiftUI

struct HeroVPIP: View {
    let value: Int
    let label: String
    var size: CGFloat = 96

    @State private var animatedProgress: CGFloat = 0

    private let ringWidth: CGFloat = 5
    private let trackOpacity: Double = 0.08

    private var progress: CGFloat {
        min(CGFloat(value) / 50.0, 1.0)
    }

    private var ringColor: Color {
        if value <= 24 {
            return .vtAccent
        } else if value <= 32 {
            return .vtAmber
        } else {
            return .vtRed
        }
    }

    var body: some View {
        let dialSize = size * 2.6

        ZStack {
            // Track ring
            Circle()
                .stroke(Color.vtText.opacity(trackOpacity), lineWidth: ringWidth)
                .frame(width: dialSize, height: dialSize)

            // Progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                )
                .frame(width: dialSize, height: dialSize)
                .rotationEffect(.degrees(-90))

            // Center content
            VStack(spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("\(value)")
                        .font(.system(size: size, weight: .ultraLight, design: .monospaced))
                        .foregroundColor(.vtText)
                        .contentTransition(.numericText())

                    Text("%")
                        .font(.system(size: size * 0.33, weight: .ultraLight, design: .monospaced))
                        .foregroundColor(.vtDim)
                }

                Text(label.uppercased())
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.vtDim)
                    .tracking(2)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
                animatedProgress = progress
            }
        }
        .onChange(of: value) {
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedProgress = progress
            }
        }
    }
}

#Preview {
    ZStack {
        Color.vtBlack.ignoresSafeArea()
        VStack(spacing: 40) {
            HeroVPIP(value: 22, label: "Lifetime VPIP", size: 88)
            HeroVPIP(value: 35, label: "Session VPIP", size: 72)
        }
    }
}
