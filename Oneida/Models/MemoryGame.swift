//
//  MemoryGame.swift
//  Oneida
//
//  Created by Alex on 30.04.2025.
//

import SwiftUI

enum MemoryGameConstants {
    static let gameDuration: TimeInterval = 45
    static let pairsCount = 6
    static let countdownDuration: Int = 2
    static let animationDuration: TimeInterval = 0.3
}

enum MemoryCardImage: Int, CaseIterable {
    case guitar = 1
    case piano
    case drums
    case saxophone
    case trumpet
    case violin
    
    var imageName: String {
        switch self {
        case .guitar: return "img11"
        case .piano: return "img22"
        case .drums: return "img33"
        case .saxophone: return "img44"
        case .trumpet: return "img55"
        case .violin: return "img66"
        }
    }
}

enum MemoryCardState {
    case faceDown
    case faceUp
    case matched
}

enum MemoryGameState: Equatable {
    case initial
    case playing
    case paused
    case finished(success: Bool)
}

struct MemoryCard: Identifiable, Equatable {
    let id = UUID()
    let imageIdentifier: Int
    var state: MemoryCardState = .faceDown
    let position: Position
    
    struct Position: Equatable {
        let row: Int
        let column: Int
        
        static func == (lhs: Position, rhs: Position) -> Bool {
            lhs.row == rhs.row && lhs.column == rhs.column
        }
    }
    
    static func == (lhs: MemoryCard, rhs: MemoryCard) -> Bool {
        lhs.id == rhs.id
    }
}

struct MemoryBoardConfiguration {
    static let boardSize = 4
    static let totalCards = 12
    
    static func generateCards() -> [MemoryCard] {
        var cards: [MemoryCard] = []
        let totalPairs = MemoryGameConstants.pairsCount
        
        for i in 1...totalPairs {
            for _ in 1...2 {
                cards.append(MemoryCard(imageIdentifier: i, position: .init(row: 0, column: 0)))
            }
        }
        
        cards.shuffle()
        
        var index = 0
        for row in 0..<3 {
            for column in 0..<4 {
                guard index < cards.count else { break }
                
                cards[index] = MemoryCard(
                    imageIdentifier: cards[index].imageIdentifier,
                    position: .init(row: row, column: column)
                )
                index += 1
            }
        }
        
        return cards
    }
}
