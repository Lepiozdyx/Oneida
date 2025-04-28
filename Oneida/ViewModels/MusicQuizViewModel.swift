//
//  MusicQuizViewModel.swift
//  Oneida
//
//  Created by Alex on 27.04.2025.
//

import SwiftUI
import Combine

class MusicQuizViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var questions: [QuizQuestion] = []
    @Published var currentQuestionIndex = 0
    @Published var selectedOptionIndex: Int?
    @Published var showCorrectAnswer = false
    @Published var quizCompleted = false
    @Published var earnedCoins = 0
    
    // MARK: - Properties
    
    weak var appViewModel: AppViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex + 1) / Double(questions.count)
    }
    
    // MARK: - Initialization
    
    init() {
        resetQuiz()
    }
    
    // MARK: - Methods
    
    func resetQuiz() {
        questions = MusicQuiz.getRandomQuestions(count: 3)
        currentQuestionIndex = 0
        selectedOptionIndex = nil
        showCorrectAnswer = false
        quizCompleted = false
        earnedCoins = 0
    }
    
    func selectOption(_ index: Int) {
        guard selectedOptionIndex == nil else { return }
        
        selectedOptionIndex = index
        showCorrectAnswer = true
        
        let isCorrect = (index == currentQuestion?.correctOptionIndex)
        if isCorrect {
            earnedCoins += 10
        }
        
        // После небольшой задержки переходим к следующему вопросу
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.proceedToNextQuestion()
        }
    }
    
    func proceedToNextQuestion() {
        showCorrectAnswer = false
        selectedOptionIndex = nil
        
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
        } else {
            completeQuiz()
        }
    }
    
    func completeQuiz() {
        quizCompleted = true
        
        appViewModel?.addCoins(earnedCoins)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.appViewModel?.navigateTo(.arcade)
            self.appViewModel?.resumeGame()
        }
    }
}
