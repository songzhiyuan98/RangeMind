import SwiftUI

struct RankSelector: View {
    @Binding var card1: String?
    @Binding var card2: String?

    private let row1 = ["A", "K", "Q", "J", "T", "9", "8"]
    private let row2 = ["7", "6", "5", "4", "3", "2"]

    var body: some View {
        VStack(spacing: 5) {
            HStack(spacing: 4) {
                ForEach(row1, id: \.self) { rank in
                    RankCard(
                        rank: rank,
                        selectionCount: selectionCount(for: rank),
                        action: { selectRank(rank) }
                    )
                }
            }

            HStack(spacing: 4) {
                ForEach(row2, id: \.self) { rank in
                    RankCard(
                        rank: rank,
                        selectionCount: selectionCount(for: rank),
                        action: { selectRank(rank) }
                    )
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func selectionCount(for rank: String) -> Int {
        var count = 0
        if card1 == rank { count += 1 }
        if card2 == rank { count += 1 }
        return count
    }

    private func selectRank(_ rank: String) {
        let count = selectionCount(for: rank)

        if count == 0 {
            if card1 == nil {
                card1 = rank
            } else if card2 == nil {
                card2 = rank
            } else {
                card2 = rank
            }
        } else if count == 1 {
            if card1 == rank && card2 == nil {
                card2 = rank
            } else if card2 == rank {
                card2 = nil
            } else if card1 == rank {
                card1 = card2
                card2 = nil
            }
        } else {
            card2 = nil
        }
    }
}

struct RankCard: View {
    let rank: String
    let selectionCount: Int
    let action: () -> Void

    var isSelected: Bool { selectionCount > 0 }

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Text(rank)
                    .font(.system(size: 17, weight: isSelected ? .semibold : .medium, design: .monospaced))
                    .foregroundColor(isSelected ? .vtBlack : .vtMuted)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(isSelected ? Color.vtText : Color.vtSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(isSelected ? Color.vtText : Color.vtBorder, lineWidth: 1)
                    )

                // Pocket pair badge
                if selectionCount == 2 {
                    Text("2")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.vtBlack)
                        .frame(width: 12, height: 12)
                        .background(Color.vtText)
                        .clipShape(Circle())
                        .offset(x: 2, y: -2)
                }
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: selectionCount)
    }
}

#Preview {
    ZStack {
        Color.vtBlack.ignoresSafeArea()
        RankSelector(card1: .constant("K"), card2: .constant("9"))
    }
}
