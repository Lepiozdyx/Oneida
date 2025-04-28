//
//  MiniGameType.swift
//  Oneida
//
//  Created by Alex on 27.04.2025.
//

import Foundation

enum MiniGameType: String, Codable, CaseIterable, Identifiable {
    case guessNumber = "guess_number"
    case memoryCards = "memory_cards"
    case sequence = "sequence"
    case maze = "maze"
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .guessNumber: return "Угадай число"
        case .memoryCards: return "Найди пару"
        case .sequence: return "Запоминайка"
        case .maze: return "Лабиринт"
        }
    }
    
    var description: String {
        switch self {
        case .guessNumber: return "Угадай число 1-999, подсказки >/<"
        case .memoryCards: return "12 карт, 6 пар, max 5 ошибок, 45 сек"
        case .sequence: return "Повторение последовательности из 6 шагов"
        case .maze: return "Найти выход за 60 с, управление свайпами"
        }
    }
    
    var reward: Int {
        switch self {
        case .guessNumber: return 20
        case .memoryCards: return 30
        case .sequence: return 30
        case .maze: return 40
        }
    }
}
