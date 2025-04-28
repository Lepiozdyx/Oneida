//  GameViewModel.swift
//  Oneida
//  Created by Alex on 27.04.2025.
//

import SwiftUI
import SpriteKit
import Combine

class GameViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var score: Int = 0
    @Published var targetNoteType: NoteType = .note1
    @Published var lives: Int = 5
    @Published var timeRemaining: Double = 10.0
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
        // Не ставим на паузу, если уже показывается какой-либо оверлей
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
    
    func pauseGame() {
        togglePause(true)
    }
    
    func resumeGame() {
        togglePause(false)
    }
    
    func resetGame() {
        // Критически важно! Сначала сбрасываем флаги оверлеев перед асинхронными операциями
        self.showVictoryOverlay = false
        self.showDefeatOverlay = false
        
        // Даем сигнал на обновление UI немедленно
        self.objectWillChange.send()
        
        // Далее выполняем остальные операции сброса
        gameTimer?.invalidate()
        targetNoteTimer?.invalidate()
        gameScene?.pauseGame()
        
        // Асинхронное выполнение остальных операций сброса
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Сбрасываем все остальные значения
            self.score = 0
            self.lives = 5
            self.timeRemaining = 60.0
            self.isPaused = false
            
            // Повторно сбрасываем флаги оверлеев для гарантии
            self.showVictoryOverlay = false
            self.showDefeatOverlay = false
            
            // Устанавливаем новые таймеры
            self.setupTimers()
            
            // Сбрасываем сцену
            self.gameScene?.resetGame()
            
            // Снова обновляем UI
            self.objectWillChange.send()
            
            print("GameViewModel полностью сброшен: lives=\(self.lives), score=\(self.score), showVictoryOverlay=\(self.showVictoryOverlay)")
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
            // Правильная нота - начисляем очки
            score += 1
            appViewModel?.gameState.notesCollected += 1
        } else {
            // Неправильная нота - отнимаем жизнь
            lives -= 1
            
            // Проверяем условие поражения
            if lives <= 0 {
                gameOver(win: false)
            }
        }
        
        // Обновляем UI
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    func didMissNote(ofType type: NoteType) {
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    func didCollectGoldCoin() {
        print("Золотая монета собрана! Запускаем квиз...")
        
        // Теперь делегируем запуск квиза в AppViewModel
        appViewModel?.startMusicQuiz()
    }
}
