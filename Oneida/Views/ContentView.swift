//
//  ContentView.swift
//  Oneida
//
//  Created by Alex on 27.04.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var settings = SettingsViewModel.shared
    
    @Environment(\.scenePhase) private var phase
    
    var body: some View {
        ZStack {
            switch appViewModel.currentScreen {
            case .menu:
                MenuView()
                    .environmentObject(appViewModel)
                
            case .levelSelect:
                LevelSelectView()
                    .environmentObject(appViewModel)
                
            case .arcade:
                GameView()
                    .environmentObject(appViewModel)
                
            case .miniGames:
                Text("Мини-игры")
                    .environmentObject(appViewModel)
                
            case .settings:
                Text("Настройки")
                    .environmentObject(appViewModel)
                
            case .shop:
                Text("Магазин")
                    .environmentObject(appViewModel)
                
            case .achievements:
                Text("Достижения")
                    .environmentObject(appViewModel)
                
            case .quiz:
                // Новый экран квиза
                if let quizViewModel = appViewModel.quizViewModel {
                    MusicQuizView(quizViewModel: quizViewModel)
                        .transition(.scale)
                        .zIndex(100)
                        .environmentObject(appViewModel)
                }
            }
        }
        .onAppear {
            if settings.musicIsOn {
                settings.playMusic()
            }
        }
        .onChange(of: phase) { newPhase in
            switch newPhase {
            case .active:
                settings.playMusic()
            case .background, .inactive:
                settings.stopMusic()
            @unknown default:
                break
            }
        }
    }
}

#Preview {
    ContentView()
}
