//
//  SequenceGameViewModel.swift
//  Oneida
//
//  Created by Alex on 30.04.2025.
//

import SwiftUI
import Combine

class SequenceGameViewModel: ObservableObject {
    // Состояние игры
    @Published private(set) var gameState: SequenceGameState = .showing
    
    // Текущая последовательность
    @Published private(set) var sequence: [SequenceImage] = []
    
    // Текущее отображаемое изображение (при показе последовательности)
    @Published private(set) var currentShowingImage: SequenceImage?
    
    // Ввод игрока
    @Published private(set) var playerInput: [SequenceImage] = []
    
    // Максимальная достигнутая длина последовательности (для сохранения прогресса)
    @Published private(set) var maxSequenceLength: Int
    
    // Текущая длина последовательности
    @Published private(set) var currentSequenceLength: Int
    
    // Таймер для показа изображений
    private var showImageTimer: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    private var showingImageIndex = 0
    
    // Ключ для хранения прогресса
    private let maxSequenceLengthKey = "oneida.sequenceGame.maxLength"
    
    init() {
        // Загружаем максимальную длину из UserDefaults
        let savedMax = UserDefaults.standard.integer(forKey: maxSequenceLengthKey)
        let initialLength = max(savedMax, SequenceGameConstants.initialSequenceLength)
        
        // Инициализируем оба свойства напрямую
        maxSequenceLength = initialLength
        currentSequenceLength = initialLength
        
        startNewGame()
    }
    
    // Начать новую игру
    func startNewGame() {
        cleanupTimers()
        
        // Генерируем новую последовательность
        sequence = generateSequence(length: currentSequenceLength)
        
        // Сбрасываем ввод игрока
        playerInput = []
        
        // Начинаем показ
        gameState = .showing
        showSequence()
    }
    
    // Игрок нажимает на изображение
    func selectImage(_ image: SequenceImage) {
        guard gameState == .playing else { return }
        
        // Добавляем выбор игрока
        playerInput.append(image)
        
        // Проверяем правильность выбора
        let inputIndex = playerInput.count - 1
        if inputIndex < sequence.count && playerInput[inputIndex].imageName == sequence[inputIndex].imageName {
            // Верный выбор
            
            // Проверяем, завершил ли игрок последовательность
            if playerInput.count == sequence.count {
                handleSuccessfulRound()
            }
        } else {
            // Ошибка - игра окончена
            handleGameOver()
        }
    }
    
    // Переход к следующему раунду после успеха
    func nextRound() {
        // Увеличиваем длину последовательности
        currentSequenceLength += 1
        
        // Обновляем максимальное достижение если нужно
        if currentSequenceLength > maxSequenceLength {
            maxSequenceLength = currentSequenceLength
            saveProgress()
        }
        
        // Начинаем новый раунд
        startNewGame()
    }
    
    // Перезапуск после поражения
    func restartAfterGameOver() {
        // Уменьшаем длину последовательности (но не меньше начальной)
        currentSequenceLength = max(currentSequenceLength - 1, SequenceGameConstants.initialSequenceLength)
        
        // Начинаем новый раунд
        startNewGame()
    }
    
    // Сохранение прогресса
    private func saveProgress() {
        UserDefaults.standard.set(maxSequenceLength, forKey: maxSequenceLengthKey)
    }
    
    // Генерация случайной последовательности
    private func generateSequence(length: Int) -> [SequenceImage] {
        var newSequence: [SequenceImage] = []
        
        for _ in 0..<length {
            newSequence.append(SequenceImage.random())
        }
        
        return newSequence
    }
    
    // Показ последовательности
    private func showSequence() {
        showingImageIndex = 0
        showNextImageInSequence()
    }
    
    private func showNextImageInSequence() {
        guard showingImageIndex < sequence.count else {
            // Вся последовательность показана, переходим к игре
            finishShowingSequence()
            return
        }
        
        // Показываем текущее изображение
        currentShowingImage = sequence[showingImageIndex]
        
        // Планируем скрытие через определенное время
        showImageTimer = Timer.publish(every: SequenceGameConstants.showImageDuration, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                self.showImageTimer?.cancel()
                self.showingImageIndex += 1
                self.showNextImageInSequence()
            }
    }
    
    private func finishShowingSequence() {
        currentShowingImage = nil
        gameState = .playing
    }
    
    private func handleSuccessfulRound() {
        gameState = .success
    }
    
    private func handleGameOver() {
        gameState = .gameOver
    }
    
    private func cleanupTimers() {
        showImageTimer?.cancel()
    }
    
    deinit {
        cleanupTimers()
    }
}
