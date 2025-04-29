//
//  AchievementViewModel.swift
//  Oneida
//
//  Created by Alex on 29.04.2025.
//

import SwiftUI
import Combine

class AchievementViewModel: ObservableObject {
    @Published var achievements: [Achievement] = Achievement.allAchievements
    @Published var isReady: Bool = false
    
    // Добавляем сильную ссылку на GameState, чтобы избежать ошибок при обращении к appViewModel
    private var gameState: GameState?
    private var cancellables = Set<AnyCancellable>()
    
    weak var appViewModel: AppViewModel? {
        didSet {
            // При установке appViewModel инициализируем gameState
            if let appViewModel = appViewModel {
                self.gameState = appViewModel.gameState
                self.isReady = true
                self.objectWillChange.send()
            }
        }
    }
    
    func isAchievementCompleted(_ id: String) -> Bool {
        // Защита от вызова до готовности модели
        guard isReady, let gameState = gameState else { return false }
        return gameState.completedAchievements.contains(id)
    }
    
    func isAchievementNotified(_ id: String) -> Bool {
        // Защита от вызова до готовности модели
        guard isReady, let gameState = gameState else { return false }
        return gameState.notifiedAchievements.contains(id)
    }
    
    func claimReward(for achievementId: String) {
        guard let achievement = Achievement.byId(achievementId),
              let appViewModel = appViewModel,
              isAchievementCompleted(achievementId),
              !isAchievementNotified(achievementId) else { return }
        
        // Add coins
        appViewModel.addCoins(achievement.reward)
        
        // Mark as notified
        if !appViewModel.gameState.notifiedAchievements.contains(achievementId) {
            appViewModel.gameState.notifiedAchievements.append(achievementId)
            // Обновляем локальную копию gameState
            self.gameState = appViewModel.gameState
            appViewModel.saveGameState()
        }
        
        // Обновляем UI
        objectWillChange.send()
    }
    
    // Helper method to check if achievement should be unlocked
    func checkAndUnlockAchievements(gameViewModel: GameViewModel) {
        guard let appViewModel = appViewModel else { return }
        let gameState = appViewModel.gameState
        
        // First Chord - 10 notes caught in a row
        if gameViewModel.consecutiveCorrectNotes >= 10 {
            unlockAchievement("first_chord")
        }
        
        // Colour Symphony - completed level without missing notes of each color
        if gameViewModel.showVictoryOverlay && gameViewModel.missedNoteColors.isEmpty {
            unlockAchievement("colour_symphony")
        }
        
        // Perfect Melody - 3 consecutive perfect levels
        if gameViewModel.showVictoryOverlay && gameViewModel.totalWrongNotes == 0 {
            appViewModel.gameState.perfectLevels += 1
            if appViewModel.gameState.perfectLevels >= 3 {
                unlockAchievement("perfect_melody")
            }
        } else if gameViewModel.totalWrongNotes > 0 {
            // Reset perfect levels counter if current level wasn't perfect
            appViewModel.gameState.perfectLevels = 0
        }
        
        // Tempo Solo - 5 notes in 5 seconds
        if gameViewModel.notesIn5Seconds >= 5 {
            unlockAchievement("tempo_solo")
        }
        
        // Colour Maestro - complete 10 levels
        if gameState.levelsCompleted >= 10 {
            unlockAchievement("colour_maestro")
        }
        
        appViewModel.saveGameState()
        // Обновляем локальную копию gameState
        self.gameState = appViewModel.gameState
    }
    
    func unlockAchievement(_ id: String) {
        guard let appViewModel = appViewModel,
              !appViewModel.gameState.completedAchievements.contains(id) else { return }
        
        appViewModel.gameState.completedAchievements.append(id)
        // Обновляем локальную копию gameState
        self.gameState = appViewModel.gameState
        appViewModel.saveGameState()
    }
}
