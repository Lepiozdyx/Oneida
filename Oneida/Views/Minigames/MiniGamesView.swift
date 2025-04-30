//
//  MiniGamesView.swift
//  Oneida
//
//  Created by Alex on 30.04.2025.
//

import SwiftUI

struct MiniGamesView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    
    @State private var settingsOpacity: Double = 0
    @State private var settingsOffset: CGFloat = 20
    
    var body: some View {
        ZStack {
            AppBackgroundView(background: Color.deepPurple)
            
            VStack {
                HStack {
                    Button {
                        svm.play()
                        appViewModel.navigateTo(.menu)
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
                
                Text("mini-games")
                    .specialFont(40)
                    .scaleEffect(titleScale)
                    .opacity(titleOpacity)
                    .onAppear {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                            titleScale = 1.0
                            titleOpacity = 1.0
                        }
                        
                        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                            settingsOpacity = 1.0
                            settingsOffset = 0
                        }
                    }

                Spacer()
                
                // Grid of mini-games
                VStack(spacing: 20) {
                    ForEach(MiniGameType.allCases) { gameType in
                        MiniGameItemView(gameType: gameType) {
                            svm.play()
                            appViewModel.startMiniGame(gameType: gameType)
                        }
                    }
                }
                .padding()
                .background(
                    Image(.frame)
                        .resizable()
                        .frame(width: 350, height: 400)
                )
                .opacity(settingsOpacity)
                .offset(y: settingsOffset)
                
                Spacer()
            }
            .padding()
        }
    }
}

struct MiniGameItemView: View {
    let gameType: MiniGameType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            MainActionView(width: 250, height: 50, text: gameType.title, textSize: 18, textColor: .black)
        }
    }
}

#Preview {
    MiniGamesView()
        .environmentObject(AppViewModel())
}
