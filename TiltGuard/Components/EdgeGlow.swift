import SwiftUI

struct EdgeGlow: View {
    let status: GlowStatus
    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .stroke(status.color, lineWidth: 1.5)
            .opacity(isAnimating ? status.opacityRange.max : status.opacityRange.min)
            .animation(
                .easeInOut(duration: status.animationDuration)
                .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

#Preview {
    ZStack {
        Color.vtBlack.ignoresSafeArea()
        VStack(spacing: 40) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.vtSurface)
                .frame(height: 100)
                .overlay(EdgeGlow(status: .warning))

            RoundedRectangle(cornerRadius: 8)
                .fill(Color.vtSurface)
                .frame(height: 100)
                .overlay(EdgeGlow(status: .danger))
        }
        .padding()
    }
}
