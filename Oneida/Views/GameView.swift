//
//  GameView.swift
//  Oneida
//
//  Created by Alex on 27.04.2025.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                SpriteKitGameView(size: geometry.size)
                    .environmentObject(appViewModel)
                    .edgesIgnoringSafeArea(.all)
                
                if let gameViewModel = appViewModel.gameViewModel {
                    GameOverlayView(gameViewModel: gameViewModel)
                        .environmentObject(appViewModel)
                }
                
                // Оверлеи игровых состояний
                if let gameVM = appViewModel.gameViewModel {
                    Group {
                        // Pause Overlay
                        if gameVM.isPaused && !gameVM.showVictoryOverlay && !gameVM.showDefeatOverlay {
                            PauseOverlayView()
                                .environmentObject(appViewModel)
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.3), value: gameVM.isPaused)
                                .zIndex(90)
                        }
                        
                        // Victory Overlay
                        if gameVM.showVictoryOverlay {
                            VictoryOverlayView()
                                .environmentObject(appViewModel)
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.3), value: gameVM.showVictoryOverlay)
                                .zIndex(100)
                        }
                        
                        // Defeat Overlay
                        if gameVM.showDefeatOverlay {
                            DefeatOverlayView()
                                .environmentObject(appViewModel)
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.3), value: gameVM.showDefeatOverlay)
                                .zIndex(100)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - SpriteKitGameView

struct SpriteKitGameView: UIViewRepresentable {
    @EnvironmentObject private var appViewModel: AppViewModel
    let size: CGSize
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.preferredFramesPerSecond = 60
        view.showsFPS = false
        view.showsNodeCount = false
        
        return view
    }
    
    func updateUIView(_ view: SKView, context: Context) {
        if appViewModel.gameViewModel == nil {
            appViewModel.gameViewModel = GameViewModel()
            appViewModel.gameViewModel?.appViewModel = appViewModel
        }
        
        if view.scene == nil {
            let scene = appViewModel.gameViewModel?.setupScene(size: size)
            view.presentScene(scene)
        }
    }
}

// MARK: - GameOverlayView

struct GameOverlayView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @ObservedObject var gameViewModel: GameViewModel
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    appViewModel.pauseGame()
                } label: {
                    Image(systemName: "pause.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                HStack {
                    Text("Цель: ")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    Circle()
                        .fill(gameViewModel.targetNoteType.color)
                        .frame(width: 24, height: 24)
                }
                
                Spacer()
                
                Text("💰 \(appViewModel.coins)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
            }
            .padding()
            
            Spacer()
            
            HStack {
                // Жизни - теперь привязаны к gameViewModel напрямую
                HStack {
                    let livesCount = max(0, gameViewModel.lives)
                    if livesCount > 0 {
                        ForEach(0..<livesCount, id: \.self) { _ in
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                        }
                    } else {
                        Text("0")
                            .foregroundColor(.red)
                            .font(.title2)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.black.opacity(0.6))
                .cornerRadius(8)
                
                Spacer()
                
                // Счет - теперь привязан к gameViewModel напрямую
                Text("Счет: \(gameViewModel.score)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                
                Spacer()
                
                // Таймер - теперь привязан к gameViewModel напрямую
                Text(timeString)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
            }
            .padding()
        }
    }
    
    private var timeString: String {
        let time = max(0, gameViewModel.timeRemaining)
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - PauseOverlayView

struct PauseOverlayView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("ПАУЗА")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                
                Button {
                    appViewModel.resumeGame()
                } label: {
                    Text("Продолжить")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Button {
                    appViewModel.restartLevel()
                } label: {
                    Text("Заново")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                
                Button {
                    appViewModel.goToMenu()
                } label: {
                    Text("Выйти")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
        }
    }
}

// MARK: - VictoryOverlayView

struct VictoryOverlayView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var showCoinAnimation = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("ПОБЕДА!")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                
                Text("+10 💰")
                    .font(.title)
                    .foregroundColor(.yellow)
                    .scaleEffect(showCoinAnimation ? 1.5 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.5), value: showCoinAnimation)
                    .onAppear {
                        showCoinAnimation = true
                    }
                
                Button {
                    appViewModel.goToNextLevel()
                } label: {
                    Text("Следующий уровень")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 250, height: 50)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                
                Button {
                    appViewModel.goToMenu()
                } label: {
                    Text("Меню")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
    }
}

// MARK: - DefeatOverlayView
struct DefeatOverlayView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("ПОРАЖЕНИЕ")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                
                Text("Счет: \(appViewModel.gameViewModel?.score ?? 0)")
                    .font(.title)
                    .foregroundColor(.white)
                
                Button {
                    appViewModel.restartLevel()
                } label: {
                    Text("Повторить")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                
                Button {
                    appViewModel.goToMenu()
                } label: {
                    Text("Меню")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
    }
}

#Preview {
    GameView()
        .environmentObject(AppViewModel())
}
