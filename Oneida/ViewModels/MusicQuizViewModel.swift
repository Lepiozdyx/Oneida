//  MusicQuizViewModel.swift
//  Oneida

import SwiftUI
import Combine

protocol MusicQuizViewModelDelegate: AnyObject {
    func quizDidComplete(earnedCoins: Int)
}

class MusicQuizViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var questions: [QuizQuestion] = []
    @Published var currentQuestionIndex = 0
    @Published var selectedOptionIndex: Int?
    @Published var showCorrectAnswer = false
    @Published var quizCompleted = false
    @Published var earnedCoins = 0
    @Published var animateProgress = false
    
    // MARK: - Properties
    
    weak var delegate: MusicQuizViewModelDelegate?
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
        animateProgress = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.animateProgress = true
        }
    }
    
    func selectOption(_ index: Int) {
        guard selectedOptionIndex == nil else { return }
        
        selectedOptionIndex = index
        showCorrectAnswer = true
        
        let isCorrect = (index == currentQuestion?.correctOptionIndex)
        if isCorrect {
            earnedCoins += 10
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.proceedToNextQuestion()
        }
    }
    
    func proceedToNextQuestion() {
        showCorrectAnswer = false
        selectedOptionIndex = nil
        
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            
            animateProgress = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.animateProgress = true
            }
        } else {
            completeQuiz()
        }
    }
    
    func completeQuiz() {
        quizCompleted = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.delegate?.quizDidComplete(earnedCoins: self.earnedCoins)
        }
    }
}
