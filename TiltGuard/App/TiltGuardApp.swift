import SwiftUI
import SwiftData

@main
struct TiltGuardApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PlayerData.self,
            SessionData.self,
            HandRecordData.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @State private var dataService: DataService?
    @State private var appearance = AppearanceManager()
    @State private var languageManager = LanguageManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if let dataService = dataService {
                    MainTabView()
                        .environment(dataService)
                        .environment(appearance)
                        .environment(languageManager)
                        .onChange(of: languageManager.language) { _, newLang in
                            dataService.language = newLang
                        }
                        .onAppear {
                            dataService.language = languageManager.language
                        }
                } else {
                    ProgressView()
                        .onAppear {
                            dataService = DataService(modelContext: sharedModelContainer.mainContext)
                        }
                }
            }
            .preferredColorScheme(appearance.mode.colorScheme)
        }
        .modelContainer(sharedModelContainer)
    }
}
