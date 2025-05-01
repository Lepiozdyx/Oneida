//
//  AchievementViewModel.swift
//  Oneida

import SwiftUI
import Combine

class AchievementViewModel: ObservableObject {
    @Published var achievements: [Achievement] = Achievement.allAchievements
    @Published var isReady: Bool = false
    
    private var gameState: GameState?
    private var cancellables = Set<AnyCancellable>()
    
    weak var appViewModel: AppViewModel? {
        didSet {
            if let appViewModel = appViewModel {
                self.gameState = appViewModel.gameState
                self.isReady = true
                self.objectWillChange.send()
            }
        }
    }
    
    func isAchievementCompleted(_ id: String) -> Bool {
        guard isReady, let gameState = gameState else { return false }
        return gameState.completedAchievements.contains(id)
    }
    
    func isAchievementNotified(_ id: String) -> Bool {
        guard isReady, let gameState = gameState else { return false }
        return gameState.notifiedAchievements.contains(id)
    }
    
    func claimReward(for achievementId: String) {
        guard let achievement = Achievement.byId(achievementId),
              let appViewModel = appViewModel,
              isAchievementCompleted(achievementId),
              !isAchievementNotified(achievementId) else { return }
        
        appViewModel.addCoins(achievement.reward)
        
        if !appViewModel.gameState.notifiedAchievements.contains(achievementId) {
            appViewModel.gameState.notifiedAchievements.append(achievementId)

            self.gameState = appViewModel.gameState
            appViewModel.saveGameState()
        }
        
        objectWillChange.send()
    }
    
    func checkAndUnlockAchievements(gameViewModel: GameViewModel) {
        guard let appViewModel = appViewModel else { return }
        let gameState = appViewModel.gameState
        
        if gameViewModel.consecutiveCorrectNotes >= 10 {
            unlockAchievement("first_chord")
        }
        
        if gameViewModel.showVictoryOverlay && gameViewModel.missedNoteColors.isEmpty {
            unlockAchievement("colour_symphony")
        }
        
        if gameViewModel.showVictoryOverlay && gameViewModel.totalWrongNotes == 0 {
            appViewModel.gameState.perfectLevels += 1
            if appViewModel.gameState.perfectLevels >= 3 {
                unlockAchievement("perfect_melody")
            }
        } else if gameViewModel.totalWrongNotes > 0 {
            appViewModel.gameState.perfectLevels = 0
        }
        
        if gameViewModel.notesIn5Seconds >= 5 {
            unlockAchievement("tempo_solo")
        }
        
        if gameState.levelsCompleted >= 10 {
            unlockAchievement("colour_maestro")
        }
        
        appViewModel.saveGameState()
        self.gameState = appViewModel.gameState
    }
    
    func unlockAchievement(_ id: String) {
        guard let appViewModel = appViewModel,
              !appViewModel.gameState.completedAchievements.contains(id) else { return }
        
        appViewModel.gameState.completedAchievements.append(id)
        self.gameState = appViewModel.gameState
        appViewModel.saveGameState()
    }
}
