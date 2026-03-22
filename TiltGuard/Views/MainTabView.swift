import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(DataService.self) private var dataService
    @Environment(LanguageManager.self) private var languageManager
    @State private var selectedTab = 0

    private var lang: AppLanguage { languageManager.language }

    var body: some View {
        ZStack(alignment: .bottom) {
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

            CustomTabBar(selectedTab: $selectedTab, lang: lang)
                .padding(.bottom, 16)
        }
        .ignoresSafeArea(.keyboard)
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
