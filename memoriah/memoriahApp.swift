import SwiftData
import SwiftUI

@main
struct MemoriahApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        .modelContainer(for: [User.self, GameSession.self, Flashcard.self])
    }
}
