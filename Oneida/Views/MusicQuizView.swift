//
//  MusicQuizView.swift
//  Oneida
//
//  Created by Alex on 27.04.2025.
//

import SwiftUI

struct MusicQuizView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    var body: some View {
        ZStack {
            // Фон
            Color.black.opacity(0.9)
                .edgesIgnoringSafeArea(.all)
            
            if let quizVM = appViewModel.quizViewModel {
                VStack(spacing: 15) {
                    // Заголовок
                    Text("МУЗЫКАЛЬНАЯ ВИКТОРИНА")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    
                    // Прогресс
                    ProgressBar(progress: quizVM.progress)
                        .frame(height: 10)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    // Если викторина завершена
                    if quizVM.quizCompleted {
                        QuizResultView(earnedCoins: quizVM.earnedCoins)
                            .environmentObject(appViewModel)
                    }
                    // Иначе показываем текущий вопрос
                    else if let question = quizVM.currentQuestion {
                        // Вопрос
                        Text(question.question)
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding()
                        
                        Spacer()
                        
                        // Варианты ответов
                        VStack(spacing: 15) {
                            ForEach(0..<question.options.count, id: \.self) { index in
                                AnswerButton(
                                    text: question.options[index],
                                    isSelected: quizVM.selectedOptionIndex == index,
                                    isCorrect: quizVM.showCorrectAnswer ? (index == question.correctOptionIndex) : nil,
                                    action: {
                                        svm.play()
                                        quizVM.selectOption(index)
                                    }
                                )
                                .disabled(quizVM.selectedOptionIndex != nil)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
}

struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .cornerRadius(5)
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: max(0, min(CGFloat(progress) * geometry.size.width, geometry.size.width)))
                    .cornerRadius(5)
            }
        }
    }
}

struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.title3)
                .bold()
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .background(backgroundColor)
                .cornerRadius(10)
                .shadow(radius: 5)
        }
    }
    
    private var backgroundColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? .green : .red
        }
        return isSelected ? .blue : Color.gray.opacity(0.7)
    }
}

struct QuizResultView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    let earnedCoins: Int
    @State private var showAnimation = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Вы заработали:")
                .font(.title2)
                .foregroundColor(.white)
            
            Text("\(earnedCoins) 💰")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.yellow)
                .scaleEffect(showAnimation ? 1.2 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.5), value: showAnimation)
                .onAppear {
                    showAnimation = true
                }
            
            Text("Викторина завершена")
                .font(.title3)
                .foregroundColor(.white)
                .padding(.top)
            
            Button {
                // Вернуться к игре
                appViewModel.navigateTo(.arcade)
            } label: {
                Text("Продолжить")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(15)
    }
}

#Preview {
    MusicQuizView()
        .environmentObject(AppViewModel())
}
