//
//  GameState.swift
//  Oneida

import Foundation

struct GameState: Codable {
    var currentLevel: Int = 1
    var maxCompletedLevel: Int = 0
    var coins: Int = 0
    var lastLoginDate: Date?
    
    // Достижения
    var completedAchievements: [String] = []
    var notifiedAchievements: [String] = []
    
    var unlockedMiniGames: [String] = ["guess_number"]
    var purchasedThemes: [String] = ["default"]
    var currentThemeId: String = "default"
    
    var purchasedInstruments: [String] = ["guitar"]
    var purchasedBackgrounds: [String] = ["bg2"]
    var currentInstrumentId: String = "guitar"
    var currentBackgroundId: String = "bg2"
    
    var tutorialCompleted: Bool = false
    
    var levelsCompleted: Int = 0
    var notesCollected: Int = 0
    var perfectLevels: Int = 0
    
    var lastDailyRewardClaimDate: Date?
    
    var maxAvailableLevel: Int {
        return min(maxCompletedLevel + 1, 15)
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
            print("[GameState] coding error: \(error)")
        }
    }
    
    static func resetProgress() {
        UserDefaults.standard.removeObject(forKey: gameStateKey)
        UserDefaults.standard.synchronize()
    }
}
