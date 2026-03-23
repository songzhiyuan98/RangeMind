import SwiftUI
import SwiftData

struct AllSessionsView: View {
    @Environment(DataService.self) private var dataService
    @Environment(LanguageManager.self) private var languageManager

    private var lang: AppLanguage { languageManager.language }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(dataService.recentSessions.enumerated()), id: \.element.id) { index, session in
                    NavigationLink {
                        SessionDetailView(session: session)
                    } label: {
                        sessionRow(session)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            withAnimation {
                                dataService.deleteSession(session)
                            }
                        } label: {
                            Label(L10n.s(.delete, lang), systemImage: "trash")
                        }
                    }

                    if index < dataService.recentSessions.count - 1 {
                        Rectangle()
                            .fill(Color.vtBorder)
                            .frame(height: 0.5)
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(Color.vtSurface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.vtBorder, lineWidth: 1)
            )
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)
        }
        .scrollIndicators(.hidden)
        .background(Color.vtBlack.ignoresSafeArea())
        .navigationTitle(L10n.s(.allSessions, lang))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sessionRow(_ session: SessionData) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 5) {
                    Text(session.dateLabel(lang))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.vtText)

                    if let title = session.title, !title.isEmpty {
                        Text("· \(title)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.vtMuted)
                            .lineLimit(1)
                    }
                }

                Text("\(session.totalHands) \(L10n.s(.handsCount, lang)) · \(session.durationFormatted(lang))")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.vtDim)

                Text(session.tableInfoLabel(lang))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.vtDim)
            }

            Spacer()

            Text("\(session.sessionVPIP)%")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .monospacedDigit()
                .foregroundColor(vpipColor(session.sessionVPIP))

            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.vtDim)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }

    private func vpipColor(_ vpip: Int) -> Color {
        switch vpip {
        case 0..<15: return .vtAccent.opacity(0.5)
        case 15..<20: return .vtAccent.opacity(0.7)
        case 20..<25: return .vtAccent
        case 25..<30: return .vtAmber
        default: return .vtRed
        }
    }
}

#Preview {
    NavigationStack {
        AllSessionsView()
    }
    .environment(DataService(modelContext: PreviewContainer.shared.mainContext))
    .environment(LanguageManager())
    .preferredColorScheme(.dark)
}
