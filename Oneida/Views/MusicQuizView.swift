//  MusicQuizView.swift
//  Oneida
//  Created by Alex on 27.04.2025.
//

import SwiftUI

struct MusicQuizView: View {
    @ObservedObject var quizViewModel: MusicQuizViewModel
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var svm = SettingsViewModel.shared
    @EnvironmentObject private var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            // Фон
            Color.black.opacity(0.85)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 15) {
                // Заголовок
                Text("МУЗЫКАЛЬНАЯ ВИКТОРИНА")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top)
                
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
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.2))
                        )
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    // Варианты ответов
                    VStack(spacing: 12) {
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
            .frame(maxWidth: 450)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(colorScheme == .dark ? .black : .white).opacity(0.1))
                    .shadow(radius: 10)
            )
            .padding(.horizontal, 20)
        }
        .onAppear {
            print("MusicQuizView appeared!")
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
                    .fill(Color.blue)
                    .frame(width: animateProgress ? max(0, min(CGFloat(progress) * geometry.size.width, geometry.size.width)) : 0)
                    .cornerRadius(5)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animateProgress)
            }
        }
    }
}

struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool?
    let action: () -> Void
    
    @State private var animateWrong = false
    @State private var animateCorrect = false
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 18, weight: .medium))
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(backgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .scaleEffect(scaleEffect)
                .rotationEffect(animateWrong ? Angle(degrees: 2) : Angle(degrees: 0))
                .offset(x: animateWrong ? -5 : 0)
                .animation(
                    isCorrect == false ? Animation.spring(response: 0.2, dampingFraction: 0.2).repeatCount(3) : .spring(),
                    value: animateWrong
                )
                .animation(
                    isCorrect == true ? Animation.spring(response: 0.3, dampingFraction: 0.6) : .spring(),
                    value: animateCorrect
                )
        }
        .shadow(radius: isSelected ? 5 : 0)
        .onChange(of: isCorrect) { _ in
            if isCorrect == false {
                animateWrong = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    animateWrong = false
                }
            }
            if isCorrect == true {
                animateCorrect = true
            }
        }
    }
    
    private var backgroundColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? .green : .red
        }
        return isSelected ? .blue : Color.gray.opacity(0.7)
    }
    
    private var scaleEffect: CGFloat {
        if isCorrect == true && animateCorrect {
            return 1.05
        }
        return 1.0
    }
}

struct QuizResultView: View {
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
                .shadow(color: .yellow.opacity(0.6), radius: showAnimation ? 10 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.5), value: showAnimation)
                .onAppear {
                    showAnimation = true
                }
            
            Text("Викторина завершена")
                .font(.title3)
                .foregroundColor(.white)
                .padding(.top)
                .opacity(showAnimation ? 1.0 : 0.0)
                .animation(.easeIn.delay(0.3), value: showAnimation)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.blue.opacity(0.2))
        )
    }
}

#Preview {
    MusicQuizView(quizViewModel: MusicQuizViewModel())
        .environmentObject(AppViewModel())
}
