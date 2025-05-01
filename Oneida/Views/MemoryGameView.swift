//
//  MemoryGameView.swift
//  Oneida

import SwiftUI

struct MemoryGameView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = MemoryGameViewModel()
    @StateObject private var svm = SettingsViewModel.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AppBackgroundView(background: Color.deepPurple)
                
                switch viewModel.gameState {
                case .playing:
                    VStack {
                        memoryGameStatusBar(
                            timeRemaining: viewModel.timeRemaining,
                            onBackTap: {
                                svm.play()
                                appViewModel.navigateTo(.miniGames)
                            },
                            onPauseTap: {
                                svm.play()
                                viewModel.togglePause()
                            }
                        )
                        .padding(.top)
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        memoryGameBoard
                            .padding()
                        
                        pairsProgressView(
                            matched: viewModel.pairsMatched,
                            total: viewModel.totalPairs
                        )
                        
                        Spacer()
                    }
                    
                case .paused:
                    pauseMenuView
                    
                case .finished(let success):
                    gameOverView(success: success)
                }
            }
            .onAppear {
                viewModel.startGameplay()
            }
            .onDisappear {
                viewModel.cleanup()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var memoryGameBoard: some View {
        VStack(spacing: 8) {
            ForEach(0..<3) { row in
                HStack(spacing: 8) {
                    ForEach(0..<4) { column in
                        let position = MemoryCard.Position(row: row, column: column)
                        if let card = viewModel.cards.first(where: {
                            $0.position.row == row && $0.position.column == column
                        }) {
                            MemoryCardView(
                                card: card,
                                onTap: {
                                    svm.play()
                                    viewModel.flipCard(at: position)
                                },
                                isInteractionDisabled: viewModel.disableCardInteraction
                            )
                            .aspectRatio(5/6, contentMode: .fit)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            Image(.frame)
                .resizable()
        )
    }
    
    private func memoryGameStatusBar(timeRemaining: TimeInterval, onBackTap: @escaping () -> Void, onPauseTap: @escaping () -> Void) -> some View {
        HStack {
            // Back button
            Button(action: onBackTap) {
                MainActionView(width: 40, height: 40, text: "", textSize: 24)
                    .overlay {
                        Image(systemName: "arrowshape.backward.circle")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.white)
                    }
            }
            
            Spacer()
            
            // Timer
            ZStack {
                Capsule()
                    .fill(Color.deepOrange)
                    .frame(width: 100, height: 40)
                    .overlay(
                        Capsule()
                            .stroke(Color.white, lineWidth: 2)
                    )
                
                Text(timeFormatted(timeRemaining))
                    .specialFont(20)
                    .foregroundStyle(timeRemaining < 10 ? .red : .white)
            }
            
            Spacer()
            
            // Pause button
            Button(action: onPauseTap) {
                MainActionView(width: 40, height: 40, text: "", textSize: 24)
                    .overlay {
                        Image(systemName: "pause.circle")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.white)
                    }
            }
        }
    }
    
    private func pairsProgressView(matched: Int, total: Int) -> some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index < matched ? Color.orange : Color.gray.opacity(0.5))
                    .frame(width: 12, height: 12)
            }
        }
    }
    
    private var pauseMenuView: some View {
        ZStack {
            Color.black.opacity(0.1)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("PAUSED")
                    .specialFont(40)
                
                Button {
                    svm.play()
                    viewModel.togglePause()
                } label: {
                    MainActionView(width: 200, height: 50, text: "Continue", textSize: 24)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.deepPurple)
                    .opacity(0.9)
                    .shadow(radius: 10)
            )
        }
    }
    
    private func gameOverView(success: Bool) -> some View {
        ZStack {
            Color.black.opacity(0.1)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text(success ? "You Win!" : "Game Over")
                    .specialFont(40, color: success ? .green : .red)
                
                Text(success
                     ? "Congratulations!"
                     : "Time's up!")
                    .specialFont(20)
                    .padding(.horizontal)
                
                Button {
                    svm.play()
                    appViewModel.navigateTo(.miniGames)
                } label: {
                    MainActionView(width: 200, height: 50, text: "Back to menu", textSize: 24)
                }
                
                Button {
                    svm.play()
                    viewModel.resetGame()
                } label: {
                    MainActionView(width: 200, height: 50, text: "Play again", textSize: 24)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.deepPurple)
                    .opacity(0.9)
                    .shadow(radius: 10)
            )
        }
    }
    
    private func timeFormatted(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%01d:%02d", mins, secs)
    }
}

#Preview {
    MemoryGameView()
        .environmentObject(AppViewModel())
}
