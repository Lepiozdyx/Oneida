//  GameViewModel.swift
//  Oneida

import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    @Published var currentScreen: AppScreen = .menu
    @Published var gameLevel: Int = 1
    @Published var coins: Int = 0
    @Published var gameState: GameState
    
    @Published var gameViewModel: GameViewModel?
    @Published var quizViewModel: MusicQuizViewModel?
    @Published var achievementViewModel: AchievementViewModel?
    
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
        if screen == .achievements {
            if achievementViewModel == nil {
                achievementViewModel = AchievementViewModel()
            }
            achievementViewModel?.appViewModel = self
        }
        
        currentScreen = screen
    }
    
    func startGame(level: Int? = nil) {
        let levelToStart = level ?? gameState.currentLevel
        gameLevel = levelToStart
        gameState.currentLevel = levelToStart
        
        gameViewModel = GameViewModel()
        gameViewModel?.appViewModel = self
        navigateTo(.arcade)
        saveGameState()
    }
    
    func goToMenu() {
        gameViewModel = nil
        quizViewModel = nil
        navigateTo(.menu)
    }
    
    func startMusicQuiz() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.quizSourceScreen = self.currentScreen
            self.quizViewModel = MusicQuizViewModel()
            self.quizViewModel?.delegate = self
            self.navigateTo(.quiz)
            self.gameViewModel?.pauseGame()
        }
    }
    
    func returnFromQuiz() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.navigateTo(self.quizSourceScreen)
            
            if self.quizSourceScreen == .arcade {
                self.gameViewModel?.resumeGame()
            }
            
            self.quizViewModel = nil
        }
    }
    
    func startMiniGame(gameType: MiniGameType) {
        switch gameType {
        case .guessNumber:
            currentScreen = .guessNumber
        case .memoryCards:
            currentScreen = .memoryCards
        case .sequence:
            currentScreen = .sequence
        }
    }
    
    func pauseGame() {
        DispatchQueue.main.async {
            self.gameViewModel?.togglePause(true)
            self.objectWillChange.send()
        }
    }
    
    func resumeGame() {
        DispatchQueue.main.async {
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
        
        if gameState.levelsCompleted >= 10 {
            let achievementVM = AchievementViewModel()
            achievementVM.appViewModel = self
            achievementVM.unlockAchievement("colour_maestro")
        }
        
        saveGameState()
    }
    
    func showDefeat() {
        saveGameState()
    }
    
    func restartLevel() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.gameViewModel?.resetGame()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.objectWillChange.send()
                
                if let gameVM = self.gameViewModel {
                    gameVM.objectWillChange.send()
                }
            }
        }
    }
    
    func goToNextLevel() {
        gameLevel += 1
        gameState.currentLevel = gameLevel
        saveGameState()
        
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
        }
    }
    
    func resetAllProgress() {
        GameState.resetProgress()
        gameState = GameState.load()
        coins = 0
        gameLevel = 1
    }
    
    func checkAchievements(gameViewModel: GameViewModel) {
        if achievementViewModel == nil {
            achievementViewModel = AchievementViewModel()
            achievementViewModel?.appViewModel = self
        }
        
        achievementViewModel?.checkAndUnlockAchievements(gameViewModel: gameViewModel)
    }
}

extension AppViewModel: MusicQuizViewModelDelegate {
    func quizDidComplete(earnedCoins: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.addCoins(earnedCoins)
            self.returnFromQuiz()
            self.objectWillChange.send()
        }
    }
}
