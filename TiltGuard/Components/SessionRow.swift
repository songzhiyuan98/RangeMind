import SwiftUI

struct SessionRow: View {
    let session: Session

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("\(session.dateLabel) · \(session.totalHands)h · \(session.sessionVPIP)%")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.vtText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.vtDim)
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
            SessionRow(session: Session(
                startTime: Date(),
                totalHands: 45,
                vpipHands: 11
            ))
            SessionRow(session: Session(
                startTime: Date().addingTimeInterval(-86400),
                totalHands: 78,
                vpipHands: 15
            ))
        }
        .padding()
    }
}
