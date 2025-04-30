//
//  GuessNumberView.swift
//  Oneida
//
//  Created by Alex on 30.04.2025.
//

import SwiftUI

struct GuessNumberView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = GuessNumberViewModel()
    @StateObject private var svm = SettingsViewModel.shared
    
    @State private var hasAwardedCoins = false
    @State private var sliderValue: Double = 500
    
    var body: some View {
        ZStack {
            AppBackgroundView(background: Color.deepPurple)
            
            VStack {
                HStack {
                    Button {
                        svm.play()
                        appViewModel.navigateTo(.miniGames)
                    } label: {
                        MainActionView(width: 40, height: 40, text: "", textSize: 24)
                            .overlay {
                                Image(systemName: "arrowshape.backward.circle")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(.white)
                            }
                    }
                    
                    Spacer()
                }
                
                Text("Guess the Number")
                    .specialFont(30)
                    .padding(.top)
                
                Spacer()
                
                VStack(spacing: 30) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.black.opacity(0.3))
                            .frame(width: 150, height: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                        
                        Text("\(Int(sliderValue))")
                            .specialFont(40, color: .orange)
                    }
                    
                    VStack(spacing: 5) {
                        Slider(value: $sliderValue, in: 0...999, step: 1)
                            .accentColor(.orange)
                            .padding(.horizontal)
                        
                        HStack {
                            Text("0")
                                .specialFont(12, color: .white.opacity(0.7))
                            
                            Spacer()
                            
                            Text("500")
                                .specialFont(12, color: .white.opacity(0.7))
                            
                            Spacer()
                            
                            Text("999")
                                .specialFont(12, color: .white.opacity(0.7))
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    HStack {
                        Button {
                            sliderValue = max(0, sliderValue - 1)
                            svm.play()
                        } label: {
                            MainActionView(width: 40, height: 40, text: "-", textSize: 24)
                        }
                        
                        Spacer()
                        
                        Button {
                            sliderValue = min(999, sliderValue + 1)
                            svm.play()
                        } label: {
                            MainActionView(width: 40, height: 40, text: "+", textSize: 24)
                        }
                    }
                    .padding(.horizontal, 70)
                    
                    Text(viewModel.feedbackMessage)
                        .specialFont(18)
                        .padding()
                        .frame(height: 80)
                    
                    // Кнопка "Угадать"
                    if case .playing = viewModel.gameState {
                        Button {
                            svm.play()
                            viewModel.makeGuess(Int(sliderValue))
                        } label: {
                            MainActionView(width: 200, height: 50, text: "Guess", textSize: 24)
                        }
                    }
                    
                    if case .guessed(let correct, _) = viewModel.gameState, !correct {
                        Button {
                            svm.play()
                            viewModel.continueGame()
                        } label: {
                            MainActionView(width: 200, height: 50, text: "Continue", textSize: 24)
                        }
                    }
                    
                    // Кнопки при победе
                    if case .guessed(let correct, _) = viewModel.gameState, correct {
                        VStack(spacing: 20) {
                            Text("Congratulations!")
                                .specialFont(30, color: .green)
                            
                            HStack(spacing: 20) {
                                Button {
                                    svm.play()
                                    hasAwardedCoins = false
                                    viewModel.startNewGame()
                                } label: {
                                    MainActionView(width: 150, height: 50, text: "Play Again", textSize: 18)
                                }
                                
                                Button {
                                    svm.play()
                                    appViewModel.navigateTo(.miniGames)
                                } label: {
                                    MainActionView(width: 150, height: 50, text: "Menu", textSize: 18)
                                }
                            }
                        }
                    }
                }
                .padding(30)
                .background(
                    Image(.frame)
                        .resizable()
                )
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            viewModel.startNewGame()
            sliderValue = 500
            hasAwardedCoins = false
        }
        .onChange(of: viewModel.gameState) { newState in
            if case .guessed(let correct, _) = newState, correct && !hasAwardedCoins {
                appViewModel.addCoins(MiniGameType.guessNumber.reward)
                hasAwardedCoins = true
            }
        }
    }
}

#Preview {
    GuessNumberView()
        .environmentObject(AppViewModel())
}
