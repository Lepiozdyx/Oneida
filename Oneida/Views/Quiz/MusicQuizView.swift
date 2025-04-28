//  MusicQuizView.swift
//  Oneida
//  Created by Alex on 27.04.2025.
//

import SwiftUI

struct MusicQuizView: View {
    @ObservedObject var quizViewModel: MusicQuizViewModel
    @StateObject private var svm = SettingsViewModel.shared
    @EnvironmentObject private var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            AppBackgroundView(background: Color.deepPurple)
            
            VStack(spacing: 15) {
                // Заголовок
                Text("bonus game")
                    .specialFont(40)
                
                // Прогресс
                ProgressBar(progress: quizViewModel.progress, animateProgress: quizViewModel.animateProgress)
                    .frame(height: 10)
                    .padding(.horizontal)
                
                Spacer()
                
                // Если викторина завершена
                if quizViewModel.quizCompleted {
                    QuizResultView(earnedCoins: quizViewModel.earnedCoins)
                }
                // Иначе показываем текущий вопрос
                else if let question = quizViewModel.currentQuestion {
                    // Вопрос
                    Text(question.question)
                        .specialFont(16)
                        .padding(40)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white, lineWidth: 2)
                        )
                    
                    Spacer()
                    
                    // Варианты ответов
                    VStack(spacing: 20) {
                        ForEach(0..<question.options.count, id: \.self) { index in
                            AnswerButton(
                                text: question.options[index],
                                isSelected: quizViewModel.selectedOptionIndex == index,
                                isCorrect: quizViewModel.showCorrectAnswer ? (index == question.correctOptionIndex) : nil,
                                action: {
                                    svm.play()
                                    quizViewModel.selectOption(index)
                                }
                            )
                            .disabled(quizViewModel.selectedOptionIndex != nil)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .frame(maxWidth: 350)
        }
    }
}

struct ProgressBar: View {
    let progress: Double
    let animateProgress: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .cornerRadius(5)
                
                Rectangle()
                    .fill(Color.yellow)
                    .frame(width: animateProgress ? max(0, min(CGFloat(progress) * geometry.size.width, geometry.size.width)) : 0)
                    .cornerRadius(5)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animateProgress)
            }
            .shadow(color: .white, radius: 1)
        }
    }
}

#Preview {
    MusicQuizView(quizViewModel: MusicQuizViewModel())
        .environmentObject(AppViewModel())
}
