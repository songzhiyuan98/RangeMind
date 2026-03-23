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
            // Schema migration failed — delete old store and recreate
            print("ModelContainer creation failed: \(error). Deleting old store.")
            let url = modelConfiguration.url
            try? FileManager.default.removeItem(at: url)
            // Also remove related SQLite files
            let dir = url.deletingLastPathComponent()
            let name = url.lastPathComponent 
            for suffix in ["-wal", "-shm"] {
                try? FileManager.default.removeItem(at: dir.appendingPathComponent(name + suffix))
            }
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer after reset: \(error)")
            }
        }
    }()

    @State private var dataService: DataService?
    @State private var appearance = AppearanceManager()
    @State private var languageManager = LanguageManager()
    @State private var showOnboarding = false
    @State private var hasCheckedAuth = false

    var body: some Scene {
        WindowGroup {
            Group {
                if let dataService = dataService {
                    ZStack {
                        MainTabView()
                            .environment(dataService)
                            .environment(appearance)
                            .environment(languageManager)
                            .onChange(of: languageManager.language) { _, newLang in
                                dataService.language = newLang
                            }

                        if showOnboarding {
                            WelcomeView {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    showOnboarding = false
                                }
                            }
                            .environment(dataService)
                            .environment(languageManager)
                            .transition(.opacity.combined(with: .scale(scale: 1.02)))
                            .zIndex(1)
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .onAppear {
                guard !hasCheckedAuth else { return }
                hasCheckedAuth = true

                let ds = DataService(modelContext: sharedModelContainer.mainContext)
                ds.language = languageManager.language
                ds.checkAppleCredentialState()
                dataService = ds
                showOnboarding = !UserDefaults.standard.bool(forKey: "has_completed_onboarding")
            }
            .preferredColorScheme(appearance.mode.colorScheme)
        }
        .modelContainer(sharedModelContainer)
    }
}
