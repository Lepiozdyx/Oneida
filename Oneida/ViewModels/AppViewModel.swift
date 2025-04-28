import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    @Published var currentScreen: AppScreen = .menu
    @Published var gameLevel: Int = 1
    @Published var coins: Int = 0
    @Published var gameState: GameState
    
    @Published var gameViewModel: GameViewModel?
    @Published var quizViewModel: MusicQuizViewModel? // Добавляем квиз на уровень AppViewModel
    
    // Добавляем специальную переменную для хранения экрана, с которого был открыт квиз
    private var quizSourceScreen: AppScreen = .arcade
    
    init() {
        self.gameState = GameState.load()
        self.coins = gameState.coins
        self.gameLevel = gameState.currentLevel
    }
    
    var currentTheme: String {
        return gameState.currentThemeId
    }
    
    func navigateTo(_ screen: AppScreen) {
        // Простой переход без сохранения предыдущего экрана
        currentScreen = screen
    }
    
    func startGame(level: Int? = nil) {
        let levelToStart = level ?? gameState.currentLevel
        gameLevel = levelToStart
        gameState.currentLevel = levelToStart
        
        // Создаем новый экземпляр GameViewModel
        gameViewModel = GameViewModel()
        gameViewModel?.appViewModel = self
        navigateTo(.arcade)
        saveGameState()
    }
    
    func goToMenu() {
        // Очищаем ViewModel перед переходом в меню
        gameViewModel = nil
        quizViewModel = nil // Обнуляем также и квиз
        navigateTo(.menu)
    }
    
    // Новый метод для запуска музыкальной викторины
    func startMusicQuiz() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Сохраняем текущий экран как источник для квиза
            self.quizSourceScreen = self.currentScreen
            
            // Создаем новый экземпляр квиза
            self.quizViewModel = MusicQuizViewModel()
            self.quizViewModel?.delegate = self
            
            // Переходим на экран квиза
            self.navigateTo(.quiz)
            
            // Приостанавливаем игру
            self.gameViewModel?.pauseGame()
            
            print("Переход на экран квиза выполнен. Источник: \(self.quizSourceScreen)")
        }
    }
    
    // Новый метод для возврата из квиза к игре
    func returnFromQuiz() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            print("Возвращаемся из квиза на экран: \(self.quizSourceScreen)")
            
            // Возвращаемся на экран-источник (обычно .arcade)
            self.navigateTo(self.quizSourceScreen)
            
            // Возобновляем игру, если вернулись на экран аркады
            if self.quizSourceScreen == .arcade {
                self.gameViewModel?.resumeGame()
            }
            
            // Обнуляем квиз-вьюмодель
            self.quizViewModel = nil
        }
    }
    
    func pauseGame() {
        // Используем DispatchQueue.main.async для обеспечения обновления UI
        DispatchQueue.main.async {
            // Явно обновляем UI после установки паузы
            self.gameViewModel?.togglePause(true)
            self.objectWillChange.send()
        }
    }
    
    func resumeGame() {
        // Используем DispatchQueue.main.async для обеспечения обновления UI
        DispatchQueue.main.async {
            // Явно обновляем UI после снятия с паузы
            self.gameViewModel?.togglePause(false)
            self.objectWillChange.send()
        }
    }
    
    func showVictory() {
        if gameLevel > gameState.maxCompletedLevel {
            gameState.maxCompletedLevel = gameLevel
        }
        
        gameState.levelsCompleted += 1
        
        coins += 10
        gameState.coins = coins
        
        saveGameState()
    }
    
    func showDefeat() {
        // Логика при поражении
        saveGameState()
    }
    
    func restartLevel() {
        // Используем DispatchQueue.main.async для обеспечения обновления UI
        DispatchQueue.main.async {
            self.gameViewModel?.resetGame()
            // Явно обновляем UI после рестарта
            self.objectWillChange.send()
        }
    }
    
    func goToNextLevel() {
        gameLevel += 1
        gameState.currentLevel = gameLevel
        saveGameState()
        
        // Сбрасываем игровое состояние вместо просто resetGame()
        DispatchQueue.main.async {
            self.gameViewModel?.resetGame()
            self.objectWillChange.send()
        }
    }
    
    func saveGameState() {
        gameState.coins = coins
        gameState.currentLevel = gameLevel
        gameState.save()
    }
    
    func addCoins(_ amount: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.coins += amount
            self.gameState.coins = self.coins
            self.saveGameState()
            
            // Можно добавить уведомление пользователя о начислении монет
            print("Монеты добавлены: +\(amount), всего: \(self.coins)")
        }
    }
    
    func resetAllProgress() {
        GameState.resetProgress()
        gameState = GameState.load()
        coins = 0
        gameLevel = 1
    }
}

// MARK: - MusicQuizViewModelDelegate
extension AppViewModel: MusicQuizViewModelDelegate {
    func quizDidComplete(earnedCoins: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Начисляем монеты
            self.addCoins(earnedCoins)
            
            // Возвращаемся на экран-источник (обычно .arcade)
            self.returnFromQuiz()
            
            // Явное обновление UI
            self.objectWillChange.send()
        }
    }
}
