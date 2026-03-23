import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(DataService.self) private var dataService
    @Environment(LanguageManager.self) private var languageManager
    @State private var selectedTab = 0

    private var lang: AppLanguage { languageManager.language }

    private var safeAreaBottom: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom ?? 0
    }

    private var tabs: [(icon: String, label: L10n.Key, tag: Int)] {
        [
            ("house",     .tabHome,  0),
            ("bolt",      .tabLive,  1),
            ("chart.bar", .tabStats, 2),
            ("person",    .tabMe,    3)
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case 0: HomeView(selectedTab: $selectedTab)
                case 1: SessionView()
                case 2: StatsView()
                case 3: SettingsView()
                default: HomeView(selectedTab: $selectedTab)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeInOut(duration: 0.25), value: selectedTab)

            // Flat tab bar
            HStack(spacing: 0) {
                ForEach(tabs, id: \.tag) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab.tag
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: selectedTab == tab.tag ? "\(tab.icon).fill" : tab.icon)
                                .font(.system(size: 18))

                            Text(L10n.s(tab.label, lang))
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(selectedTab == tab.tag ? .vtText : .vtDim)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, safeAreaBottom)
            .background(Color.vtBlack)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    MainTabView()
        .environment(DataService(modelContext: PreviewContainer.shared.mainContext))
        .environment(AppearanceManager())
        .environment(LanguageManager())
        .preferredColorScheme(.dark)
}

// Preview helper
struct PreviewContainer {
    static let shared: ModelContainer = {
        let schema = Schema([PlayerData.self, SessionData.self, HandRecordData.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: [config])
    }()
}
