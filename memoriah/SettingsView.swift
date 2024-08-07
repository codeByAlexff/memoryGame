import SwiftData
import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {
    // MARK: Internal

    var body: some View {
        Form {
            Section(header: Text("Appearance")) {
                HStack {
//                    Spacer()
                    Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                        .foregroundColor(isDarkMode ? .yellow : .orange)
                    Toggle(isDarkMode ? "Dark Mode" : "Light Mode", isOn: $isDarkMode)
                }
            }

            Section(header: Text("Data Management")) {
                Button("Reset Scores") {
                    showingResetAlert = true
                }
                .foregroundColor(.red)

                Button("Delete All Information") {
                    showingDeleteAlert = true
                }
                .foregroundColor(.red)
            }

            Section(header: Text("App Information")) {
                Text("Version \(appVersion)")
            }
        }
        .navigationTitle("Settings")
        .preferredColorScheme(isDarkMode ? .dark : .light)

        .alert("Reset Scores", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                resetScores()
            }
        } message: {
            Text("Are you sure you want to reset all scores? This action cannot be undone.")
        }
        .alert("Delete All Information", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteAllInformation()
            }
        } message: {
            Text("Are you sure you want to delete all information? This action cannot be undone.")
        }
    }

    // MARK: Private

    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.modelContext) private var modelContext
    @State private var showingResetAlert = false
    @State private var showingDeleteAlert = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    private func resetScores() {
        do {
            try modelContext.delete(model: GameSession.self)
        } catch {
            print("Failed to reset scores: \(error)")
        }
    }

    private func deleteAllInformation() {
        do {
            try modelContext.delete(model: GameSession.self)
            try modelContext.delete(model: User.self)
        } catch {
            print("Failed to delete all information: \(error)")
        }
    }
}

// MARK: - PreviewProvider

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
