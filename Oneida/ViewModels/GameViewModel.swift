//
//  GameViewModel.swift
//  Oneida
//
//  Created by Alex on 27.04.2025.
//

import SwiftUI
import SpriteKit
import Combine

class GameViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var score: Int = 0
    @Published var targetNoteType: NoteType = .note1
    @Published var lives: Int = 3
    @Published var timeRemaining: Double = 60.0
    @Published var isPaused: Bool = false
    @Published var showVictoryOverlay: Bool = false
    @Published var showDefeatOverlay: Bool = false
    
    // MARK: - Private Properties
    private var gameScene: GameScene?
    private var targetNoteTimer: Timer?
    private var gameTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Properties
    weak var appViewModel: AppViewModel?
    
    // MARK: - Initialization
    init() {
        setupTimers()
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - Public Methods
    
    func setupScene(size: CGSize) -> GameScene {
        let scene = GameScene(size: size)
        scene.scaleMode = .aspectFill
        scene.gameDelegate = self
        gameScene = scene
        return scene
    }
    
    func togglePause(_ paused: Bool) {
        // Проверка, чтобы не переключать в паузу, если уже отображается один из оверлеев
        if paused && (showVictoryOverlay || showDefeatOverlay) {
            return
        }
        
        // Устанавливаем состояние паузы
        isPaused = paused
        
        if paused {
            // Останавливаем таймеры при паузе
            gameTimer?.invalidate()
            targetNoteTimer?.invalidate()
            gameScene?.pauseGame()
        } else {
            // Возобновляем таймеры при снятии с паузы
            startGameTimer()
            startTargetNoteTimer()
            gameScene?.resumeGame()
        }
        
        // Явно вызываем обновление UI через main thread
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    func resetGame() {
        // Сначала отменяем все таймеры
        gameTimer?.invalidate()
        targetNoteTimer?.invalidate()
        
        // Сбрасываем все игровые параметры
        score = 0
        lives = 3
        timeRemaining = 60.0
        isPaused = false
        showVictoryOverlay = false
        showDefeatOverlay = false
        
        // Устанавливаем новые таймеры
        setupTimers()
        
        // Сбрасываем состояние сцены
        gameScene?.resetGame()
        
        // Явно вызываем обновление UI
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupTimers() {
        // Начальный целевой цвет
        targetNoteType = NoteType.random(excludingKey: true)
        
        // Запускаем таймеры с нуля
        gameTimer?.invalidate()
        targetNoteTimer?.invalidate()
        
        startGameTimer()
        startTargetNoteTimer()
    }
    
    private func startGameTimer() {
        gameTimer?.invalidate()
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, !self.isPaused else { return }
            
            self.timeRemaining -= 0.1
            
            // Обновляем UI с каждым тиком таймера
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
            
            // Проверяем, закончилось ли время
            if self.timeRemaining <= 0 {
                self.gameOver(win: true)
            }
        }
    }
    
    private func startTargetNoteTimer() {
        targetNoteTimer?.invalidate()
        
        // Меняем целевую ноту каждые 10 секунд
        targetNoteTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            guard let self = self, !self.isPaused else { return }
            
            var newType: NoteType
            repeat {
                newType = NoteType.random(excludingKey: true)
            } while newType == self.targetNoteType
            
            self.targetNoteType = newType
            
            // Обновляем UI при смене целевой ноты
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    private func gameOver(win: Bool) {
        // Остановка всех игровых процессов
        cleanup()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Показываем соответствующий оверлей
            if win {
                self.showVictoryOverlay = true
                self.appViewModel?.showVictory()
            } else {
                self.showDefeatOverlay = true
                self.appViewModel?.showDefeat()
            }
            
            // Явное обновление UI
            self.objectWillChange.send()
        }
    }
    
    private func cleanup() {
        gameTimer?.invalidate()
        targetNoteTimer?.invalidate()
        gameScene?.pauseGame()
        isPaused = true
    }
}

// MARK: - GameSceneDelegate
extension GameViewModel: GameSceneDelegate {
    func didCollectNote(ofType type: NoteType) {
        if type == targetNoteType {
            // Правильная нота
            score += 1
            appViewModel?.gameState.notesCollected += 1
        } else {
            // Неправильная нота
            lives -= 1
            if lives <= 0 {
                gameOver(win: false)
            }
        }
        
        // Обновляем UI
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    func didMissNote() {
        lives -= 1
        
        // Обновляем UI
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
        
        if lives <= 0 {
            gameOver(win: false)
        }
    }
    
    func didCollectGoldCoin() {
        // Переходим к бонусной викторине
        appViewModel?.startQuiz()
    }
}
