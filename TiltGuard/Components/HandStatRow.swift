import SwiftUI

struct HandStatRow: View {
    let stat: HandStat

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(stat.handType)
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(.vtText)

                Spacer()

                Text("×\(stat.playCount)")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(.vtMuted)

                Text("\(stat.winRate)%")
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundColor(.vtText)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.vtElevated)
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.vtAccent)
                        .frame(width: geometry.size.width * CGFloat(stat.winRate) / 100, height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(14)
        .background(Color.vtSurface)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(Color.vtBorder, lineWidth: 1)
        )
    }
}

#Preview {
    ZStack {
        Color.vtBlack.ignoresSafeArea()
        VStack(spacing: 10) {
            HandStatRow(stat: HandStat(handType: "AKs", playCount: 47, winCount: 29))
            HandStatRow(stat: HandStat(handType: "KQs", playCount: 35, winCount: 19))
            HandStatRow(stat: HandStat(handType: "AJo", playCount: 28, winCount: 13))
        }
        .padding()
    }
}
