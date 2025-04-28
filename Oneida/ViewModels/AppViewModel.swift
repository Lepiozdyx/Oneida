//
//  AppViewModel.swift
//  Oneida
//
//  Created by Alex on 27.04.2025.
//

import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    @Published var currentScreen: AppScreen = .menu
    @Published var gameLevel: Int = 1
    @Published var coins: Int = 0
    @Published var gameState: GameState
    
    @Published var gameViewModel: GameViewModel?
    @Published var quizViewModel: MusicQuizViewModel?
    
    init() {
        self.gameState = GameState.load()
        self.coins = gameState.coins
        self.gameLevel = gameState.currentLevel
        
        checkDailyBonus()
    }
    
    var currentTheme: String {
        return gameState.currentThemeId
    }
    
    func navigateTo(_ screen: AppScreen) {
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
    
    func startQuiz() {
        quizViewModel = MusicQuizViewModel()
        quizViewModel?.appViewModel = self
        navigateTo(.musicQuiz)
    }
    
    func goToMenu() {
        // Очищаем ViewModel перед переходом в меню
        gameViewModel = nil
        quizViewModel = nil
        navigateTo(.menu)
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
    
    func checkDailyBonus() {
        let calendar = Calendar.current
        
        if let lastLoginDate = gameState.lastLoginDate {
            if !calendar.isDateInToday(lastLoginDate) {
                coins += 20
                gameState.coins = coins
            }
        }
        
        gameState.lastLoginDate = Date()
        saveGameState()
    }
    
    func addCoins(_ amount: Int) {
        coins += amount
        gameState.coins = coins
        saveGameState()
    }
    
    func resetAllProgress() {
        GameState.resetProgress()
        gameState = GameState.load()
        coins = 0
        gameLevel = 1
    }
}
