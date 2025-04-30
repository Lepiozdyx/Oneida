//
//  VictoryOverlayView.swift
//  Oneida
//
//  Created by Alex on 28.04.2025.
//

import SwiftUI

struct VictoryOverlayView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var showCoinAnimation = false
    @State private var navigatingToNextLevel = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            Image(.guitar)
                .resizable()
                .frame(width: 150, height: 450)
                .rotationEffect(Angle(degrees: -30))
            
            Image(.win)
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("you win!")
                    .specialFont(40, color: .green)
                    .shadow(color: .green, radius: 30)
                
                HStack {
                    Text("+10")
                        .specialFont(22)
                    
                    Image(.goldCoin)
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                .scaleEffect(showCoinAnimation ? 1.5 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.5), value: showCoinAnimation)
                .onAppear {
                    showCoinAnimation = true
                }
                
                Button {
                    // Защита от двойных нажатий
                    guard !navigatingToNextLevel else { return }
                    navigatingToNextLevel = true
                    
                    // Сначала явно скрываем оверлей, даже до вызова goToNextLevel
                    if let gameVM = appViewModel.gameViewModel {
                        gameVM.showVictoryOverlay = false
                    }
                    
                    // Небольшая задержка перед переходом для завершения анимации исчезновения
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        appViewModel.goToNextLevel()
                        // Дополнительно обновляем UI
                        appViewModel.objectWillChange.send()
                    }
                } label: {
                    MainActionView(width: 200, height: 50, text: "next level", textSize: 24, textColor: .green)
                }
                .disabled(navigatingToNextLevel) // Блокируем кнопку после нажатия
                
                Button {
                    // Защита от двойных нажатий
                    guard !navigatingToNextLevel else { return }
                    navigatingToNextLevel = true
                    
                    // Сначала явно скрываем оверлей
                    if let gameVM = appViewModel.gameViewModel {
                        gameVM.showVictoryOverlay = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        appViewModel.goToMenu()
                    }
                } label: {
                    MainActionView(width: 200, height: 50, text: "menu", textSize: 24)
                }
                .disabled(navigatingToNextLevel)
            }
            .padding()
        }
    }
}

#Preview {
    VictoryOverlayView()
        .environmentObject(AppViewModel())
}
