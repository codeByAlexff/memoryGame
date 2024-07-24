import SwiftData
import SwiftUI
import AVFoundation

// MARK: - GameBoardView

struct GameBoardView: View {
    let mode: GameMode
    @State private var cards: [Card] = []
    @State private var timeElapsed: Double = 0
    @State private var score: Int = 0
    @State private var flippedCardIndices: Set<Int> = []
    @State private var isGameOver = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @State private var activeError: GameError?
    @Query private var users: [User]
    @State private var consecutiveGames = 0
    @State private var showAllCards = false
    @State private var timeLimit: Double = 30.0
    @State private var showDifficultySelection = false
    @State private var difficulty: Difficulty = .medium
    @State private var timer: Timer? = nil

    let imageNames = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17"] // All 17 image names

    var body: some View {
        ZStack {
            if showDifficultySelection && mode == .timed {
                VStack {
                    Text("Select Difficulty")
                        .font(.system(size: 24, weight: .bold))
                    Button("Easy (2 minutes)") {
                        difficulty = .easy
                        timeLimit = 120.0
                        showDifficultySelection = false
                        setupGame()
                    }
                    .padding()
                    Button("Medium (1 minute)") {
                        difficulty = .medium
                        timeLimit = 60.0
                        showDifficultySelection = false
                        setupGame()
                    }
                    .padding()
                    Button("Hard (30 seconds)") {
                        difficulty = .hard
                        timeLimit = 30.0
                        showDifficultySelection = false
                        setupGame()
                    }
                    .padding()
                }
            } else if !isGameOver {
                VStack {
                    Text("Score: \(score)")
                        .font(.system(size: 24, weight: .bold))
                    Text(timerText)
                        .font(.system(size: 36, weight: .bold))
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) { // 3 columns
                        ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                            CardView(card: card, isFlipped: flippedCardIndices.contains(index) || card.isMatched || showAllCards) {
                                withAnimation {
                                    flipCard(at: index)
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    if mode == .timed && consecutiveGames == 0 {
                        showDifficultySelection = true
                    } else {
                        setupGame()
                    }
                }
                .onDisappear {
                    timer?.invalidate()
                    SoundManager.shared.stopBackgroundMusic() // Stop any playing background music
                }
            } else {
                GameCompletionView(
                    mode: mode == .practice ? "Practice" : "Timed",
                    score: score,
                    timeElapsed: timeElapsed,
                    timeLimit: mode == .timed ? timeLimit : nil,
                    playerWon: cards.allSatisfy(\.isMatched),
                    onDismiss: { isExitingToMainMenu in
                        saveGameSession(isExitingToMainMenu: isExitingToMainMenu, playerWon: cards.allSatisfy(\.isMatched))
                        if isExitingToMainMenu {
                            resetConsecutiveGames()
                        }
                        dismiss()
                    },
                    onPlayAgain: {
                        saveGameSession(isExitingToMainMenu: false, playerWon: cards.allSatisfy(\.isMatched))
                        setupGame()
                    },
                    onNewGame: {
                        resetConsecutiveGames()
                        setupGame()
                    }
                )
            }
        }
        .alert(item: $activeError) { error in
            Alert(
                title: Text("Error"),
                message: Text(error.localizedDescription),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var timerText: String {
        let remainingTime = max(0, timeLimit - timeElapsed)
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func setupGame() {
        // Ensure you have enough images for 3 columns (at least 6 images for pairs)
        guard imageNames.count >= 6 else {
            // Handle the case where you don't have enough images
            print("Not enough images for 3 columns")
            return
        }
        
        

        var selectedImageNames = Array(imageNames.shuffled().prefix(6)) // Select 6 images
        selectedImageNames = selectedImageNames + selectedImageNames // Duplicate for pairs
        cards = selectedImageNames.shuffled().map { Card(content: $0) }

        consecutiveGames += 1

        if consecutiveGames == 0 {
            score = 0 // Reset score only for a new game
        }
        timeElapsed = 0
        flippedCardIndices.removeAll()
        isGameOver = false
        showAllCards = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showAllCards = false
        }

        startTimer()
        SoundManager.shared.playBackgroundMusic(named: "bg2") // Start bg2 music
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            updateTimer()
        }
    }

    private func flipCard(at index: Int) {
        guard !cards[index].isMatched, flippedCardIndices.count < 2 else { return }

        if flippedCardIndices.contains(index) {
            flippedCardIndices.remove(index)
        } else {
            flippedCardIndices.insert(index)
            playHapticFeedback()
            SoundManager.shared.playSound(named: "flip") // Play flip sound
            if flippedCardIndices.count == 2 {
                checkForMatch()
            }
        }
    }

    private func playHapticFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }

    private func checkForMatch() {
        let flippedCards = flippedCardIndices.map { cards[$0] }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if flippedCards[0].content == flippedCards[1].content {
                for index in flippedCardIndices {
                    cards[index].isMatched = true
                }
                score += 4
                SoundManager.shared.playSound(named: "match") // Play match sound effect
                if cards.allSatisfy(\.isMatched) {
                    endGame(playerWon: true)
                }
            } else {
                score = max(0, score - 1) // Deduct a point, but don't go below 0
            }
            flippedCardIndices.removeAll()
        }
    }

    private func updateTimer() {
        if !isGameOver {
            timeElapsed += 1
            if mode == .timed, timeElapsed >= timeLimit {
                endGame(playerWon: cards.allSatisfy(\.isMatched))
            }
        }
    }

    private func endGame(playerWon: Bool) {
        isGameOver = true
        timer?.invalidate()

        // Stop bg2 music
        SoundManager.shared.stopBackgroundMusic()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Ensure background music stops
            if playerWon {
                SoundManager.shared.playSound(named: "win") // Play win sound effect
            } else {
                SoundManager.shared.playSound(named: "lose") // Play lose sound effect
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // Wait 5 seconds to start bg music
            SoundManager.shared.playBackgroundMusic(named: "bg")
        }

        saveGameSession(isExitingToMainMenu: false, playerWon: playerWon)
    }

    private func resetConsecutiveGames() {
        consecutiveGames = 0
    }

    private func saveGameSession(isExitingToMainMenu: Bool, playerWon: Bool) {
        guard let user = fetchOrCreateUser() else {
            handleError(GameError.failedToFetchUser)
            return
        }

        if isExitingToMainMenu {
            resetConsecutiveGames()
        }

        let newSession = GameSession(
            data: Date(),
            id: UUID(),
            mode: mode == .practice ? "Practice" : "Timed",
            score: Int32(score),
            timeElapsed: timeElapsed
        )
        newSession.user = user

        user.gamesPlayed += 1
        if playerWon, timeElapsed < user.bestTime || user.bestTime == 0 {
            user.bestTime = timeElapsed
        }

        modelContext.insert(newSession)
    }

    private func fetchOrCreateUser() -> User? {
            if let user = users.first {
                return user
            } else {
                let newUser = User(avatar: "😀", bestTime: 0, gamesPlayed: 0, userName: "Player")
                modelContext.insert(newUser)
                return newUser
            }
        }

        private func handleError(_ error: GameError) {
            activeError = error
        }
    }

    // MARK: - GameMode

    enum GameMode {
        case practice, timed
    }

    // MARK: - Difficulty

    enum Difficulty {
        case easy, medium, hard
    }

    // MARK: - GameError

    enum GameError: Error, LocalizedError, Identifiable {
        case invalidMove
        case gameOver
        case failedToSaveGame
        case failedToFetchUser

        // MARK: Internal

        var id: String {
            switch self {
            case .invalidMove: return "invalidMove"
            case .gameOver: return "gameOver"
            case .failedToSaveGame: return "failedToSaveGame"
            case .failedToFetchUser: return "failedToFetchUser"
            }
        }

        var errorDescription: String? {
            switch self {
            case .failedToSaveGame:
                return "Failed to save the game session. Please try again."
            case .failedToFetchUser:
                return "Failed to fetch or create user. Please restart the app."
            case .invalidMove:
                return "Invalid move."
            case .gameOver:
                return "Game over."
            }
        }
    }
