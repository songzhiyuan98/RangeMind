import SwiftUI

struct HeroVPIP: View {
    let value: Int
    let label: String
    var size: CGFloat = 96

    var body: some View {
        VStack(spacing: 6) {
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
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.vtDim)
                .tracking(2)
        }
    }
}

#Preview {
    ZStack {
        Color.vtBlack.ignoresSafeArea()
        HeroVPIP(value: 23, label: "Session VPIP")
    }
}
