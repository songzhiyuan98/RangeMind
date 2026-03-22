import SwiftUI

struct StatsCard: View {
    let thirtyMinVPIP: Int
    let lifetimeVPIP: Int

    var body: some View {
        HStack(spacing: 0) {
            StatItem(value: "\(thirtyMinVPIP)%", label: "30MIN")
            StatItem(value: "\(lifetimeVPIP)%", label: "LIFETIME")
        }
        .padding(.vertical, 16)
        .background(Color.vtSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.vtBorder, lineWidth: 1)
        )
    }
}

struct StatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .light, design: .monospaced))
                .monospacedDigit()
                .foregroundColor(.vtText)

            Text(label)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(.vtDim)
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ZStack {
        Color.vtBlack.ignoresSafeArea()
        StatsCard(thirtyMinVPIP: 34, lifetimeVPIP: 21)
            .padding()
    }
}
