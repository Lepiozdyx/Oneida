//
//  GameOverlayView.swift
//  Oneida

import SwiftUI

struct GameOverlayView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @ObservedObject var gameViewModel: GameViewModel
    
    @State private var currentLives: Int = 5
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    appViewModel.pauseGame()
                } label: {
                    MainActionView(width: 40, height: 40, text: "", textSize: 24)
                        .overlay {
                            Image(systemName: "line.horizontal.3")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.white)
                        }
                }
                
                Spacer()
                
                CounterView(amount: gameViewModel.score)
                
                Spacer()
                
                Circle()
                    .fill(gameViewModel.targetNoteType.color)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                    )
            }
            .padding(.horizontal)
            .padding(.top)
            
            HStack(alignment: .top) {
                VStack {
                    let livesCount = max(0, gameViewModel.lives)
                    if livesCount > 0 {
                        ForEach(0..<livesCount, id: \.self) { _ in
                            Image(systemName: "heart.fill")
                                .resizable()
                                .frame(width: 17, height: 15)
                                .foregroundColor(.red)
                        }
                    }
                }
                .id("lives-\(gameViewModel.lives)")
                
                Spacer()
                
                Text(timeString)
                    .specialFont(20)
            }
            .padding()
            
            Spacer()
        }
        .onChange(of: gameViewModel.lives) { newValue in
            currentLives = newValue
        }
        .onAppear {
            currentLives = gameViewModel.lives
        }
    }
    
    private var timeString: String {
        let time = max(0, gameViewModel.timeRemaining)
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    ZStack {
        AppBackgroundView(background: Color.deepPurple)
        
        GameOverlayView(gameViewModel: GameViewModel())
            .environmentObject(AppViewModel())
    }
}
