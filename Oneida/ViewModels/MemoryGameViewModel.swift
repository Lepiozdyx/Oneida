//
//  MemoryGameViewModel.swift
//  Oneida


import SwiftUI
import Combine

@MainActor
final class MemoryGameViewModel: ObservableObject {
    
    @Published private(set) var gameState: MemoryGameState = .playing
    @Published private(set) var cards: [MemoryCard] = []
    @Published private(set) var timeRemaining: TimeInterval = MemoryGameConstants.gameDuration
    @Published private(set) var firstCardRevealed: MemoryCard? = nil
    @Published private(set) var secondCardRevealed: MemoryCard? = nil
    @Published private(set) var isProcessingPair = false
    
    var disableCardInteraction: Bool {
        let faceUpCount = cards.filter { $0.state == .faceUp }.count
        return gameState != .playing ||
               isProcessingPair ||
               faceUpCount >= 2
    }
    
    var pairsMatched: Int {
        cards.filter { $0.state == .matched }.count / 2
    }
    
    var totalPairs: Int {
        MemoryGameConstants.pairsCount
    }
    
    private var gameTimer: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    private let onGameComplete: ((Bool) -> Void)?
    
    init(onGameComplete: ((Bool) -> Void)? = nil) {
        self.onGameComplete = onGameComplete
        setupNewGame()
    }
    
    func setupNewGame() {
        cards = MemoryBoardConfiguration.generateCards()
        timeRemaining = MemoryGameConstants.gameDuration
        firstCardRevealed = nil
        secondCardRevealed = nil
        isProcessingPair = false
        startGameplay()
    }
    
    func resetGame() {
        cleanup()
        setupNewGame()
    }
    
    func pauseGame() {
        guard case .playing = gameState else { return }
        gameState = .paused
        gameTimer?.cancel()
    }
    
    func resumeGame() {
        guard case .paused = gameState else { return }
        gameState = .playing
        startGameTimer()
    }
    
    func togglePause() {
        if case .paused = gameState {
            resumeGame()
        } else if case .playing = gameState {
            pauseGame()
        }
    }
    
    func completeGame() {
        guard case .finished(let success) = gameState else { return }
        onGameComplete?(success)
    }
    
    func cleanup() {
        gameTimer?.cancel()
    }
    
    func flipCard(at position: MemoryCard.Position) {
        if disableCardInteraction {
            return
        }
        
        guard let cardIndex = cards.firstIndex(where: { $0.position == position }) else { return }
        let card = cards[cardIndex]
        guard card.state == .faceDown else { return }
        
        if let firstCard = firstCardRevealed, secondCardRevealed == nil {
            secondCardRevealed = card
            
            var updatedCards = cards
            updatedCards[cardIndex].state = .faceUp
            cards = updatedCards
            
            isProcessingPair = true
            
            if firstCard.imageIdentifier == card.imageIdentifier {
                handleMatchingPair(first: firstCard, second: card)
            } else {
                handleNonMatchingPair(first: firstCard, second: card)
            }
        }

        else if firstCardRevealed == nil {
            firstCardRevealed = card
            
            var updatedCards = cards
            updatedCards[cardIndex].state = .faceUp
            cards = updatedCards
        }
    }
    
    func startGameplay() {
        gameState = .playing
        startGameTimer()
    }
    
    private func startGameTimer() {
        gameTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if self.timeRemaining <= 0.1 {
                    self.finishGame(success: false)
                } else {
                    self.timeRemaining -= 0.1
                }
            }
    }
    
    private func handleMatchingPair(first: MemoryCard, second: MemoryCard) {
        DispatchQueue.main.asyncAfter(deadline: .now() + MemoryGameConstants.animationDuration) { [weak self] in
            guard let self = self else { return }
            
            var updatedCards = self.cards
            
            if let firstIndex = updatedCards.firstIndex(where: { $0.position == first.position }) {
                updatedCards[firstIndex].state = .matched
            }
            
            if let secondIndex = updatedCards.firstIndex(where: { $0.position == second.position }) {
                updatedCards[secondIndex].state = .matched
            }
            
            self.cards = updatedCards
            
            self.firstCardRevealed = nil
            self.secondCardRevealed = nil
            self.isProcessingPair = false
            
            if self.allCardsMatched() {
                self.finishGame(success: true)
            }
        }
    }
    
    private func handleNonMatchingPair(first: MemoryCard, second: MemoryCard) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            var updatedCards = self.cards
            
            if let firstIndex = updatedCards.firstIndex(where: { $0.position == first.position }) {
                updatedCards[firstIndex].state = .faceDown
            }
            
            if let secondIndex = updatedCards.firstIndex(where: { $0.position == second.position }) {
                updatedCards[secondIndex].state = .faceDown
            }
            
            self.cards = updatedCards
            
            self.firstCardRevealed = nil
            self.secondCardRevealed = nil
            self.isProcessingPair = false
        }
    }
    
    private func allCardsMatched() -> Bool {
        return cards.allSatisfy { card in
            card.state == .matched
        }
    }
    
    private func finishGame(success: Bool) {
        gameTimer?.cancel()
        gameState = .finished(success: success)
    }
}
