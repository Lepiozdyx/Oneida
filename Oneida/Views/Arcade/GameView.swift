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
    
    // Добавляем состояние для отслеживания хитпоинтов
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
    GameView()
        .environmentObject(AppViewModel())
}
