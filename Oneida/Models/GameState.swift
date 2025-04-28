//
//  GameState.swift
//  Oneida
//
//  Created by Alex on 27.04.2025.
//

import Foundation

struct GameState: Codable {
    var currentLevel: Int = 1
    var maxCompletedLevel: Int = 0
    var coins: Int = 0
    var lastLoginDate: Date?
    var completedAchievements: [String] = []
    var notifiedAchievements: [String] = []
    var unlockedMiniGames: [String] = ["guess_number"] // Начальная разблокированная мини-игра
    var purchasedThemes: [String] = ["default"]
    var currentThemeId: String = "default"
    var tutorialCompleted: Bool = false
    
    var levelsCompleted: Int = 0
    var notesCollected: Int = 0
    var perfectLevels: Int = 0
    
    var lastDailyRewardClaimDate: Date?
    
    var maxAvailableLevel: Int {
        return min(maxCompletedLevel + 1, 15) // Всего 15 уровней
    }
}

extension GameState {
    private static let gameStateKey = "oneidaGameState"
    
    static func load() -> GameState {
        guard let data = UserDefaults.standard.data(forKey: gameStateKey) else {
            return GameState()
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let gameState = try decoder.decode(GameState.self, from: data)
            return gameState
        } catch {
            return GameState()
        }
    }
    
    func save() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            let encoded = try encoder.encode(self)
            UserDefaults.standard.set(encoded, forKey: GameState.gameStateKey)
            UserDefaults.standard.synchronize()
        } catch {
            print("[GameState] Ошибка при кодировании: \(error)")
        }
    }
    
    static func resetProgress() {
        UserDefaults.standard.removeObject(forKey: gameStateKey)
        UserDefaults.standard.synchronize()
    }
}
