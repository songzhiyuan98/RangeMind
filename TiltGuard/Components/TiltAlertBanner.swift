import SwiftUI

struct TiltAlertBanner: View {
    let alert: TiltAlert

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(alert.color)
                .frame(width: 5, height: 5)

            Text(alert.message)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(alert.color)
                .lineLimit(1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(alert.color.opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(alert.color.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

#Preview {
    ZStack {
        Color.vtBlack.ignoresSafeArea()
        VStack(spacing: 12) {
            TiltAlertBanner(alert: .vpipHigh)
            TiltAlertBanner(alert: .possibleTilt)
            TiltAlertBanner(alert: .rangeExpanding)
        }
        .padding()
    }
}
