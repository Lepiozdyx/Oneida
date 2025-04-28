//
//  LevelSelectView.swift
//  Oneida
//
//  Created by Alex on 27.04.2025.
//

import SwiftUI

struct LevelSelectView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    // Определяем количество уровней и их расположение в сетке
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    private let totalLevels = 15
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    svm.play()
                    appViewModel.navigateTo(.menu)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title)
                        .padding()
                }
                
                Spacer()
                
                Text("Выбор уровня")
                    .font(.title)
                    .bold()
                
                Spacer()
                
                Text("\(appViewModel.coins) 💰")
                    .font(.title2)
                    .padding()
            }
            
            Spacer()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(1...totalLevels, id: \.self) { level in
                        LevelTileView(level: level)
                            .environmentObject(appViewModel)
                    }
                }
                .padding()
            }
        }
    }
}

struct LevelTileView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    let level: Int
    
    private var isLocked: Bool {
        return level > appViewModel.gameState.maxAvailableLevel
    }
    
    var body: some View {
        Button {
            if !isLocked {
                svm.play()
                appViewModel.startGame(level: level)
            }
        } label: {
            ZStack {
                Rectangle()
                    .fill(isLocked ? Color.gray : Color.blue)
                    .frame(width: 80, height: 80)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                
                if isLocked {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.white)
                        .font(.title)
                } else {
                    Text("\(level)")
                        .foregroundColor(.white)
                        .font(.title)
                        .bold()
                }
            }
        }
        .disabled(isLocked)
    }
}

#Preview {
    LevelSelectView()
        .environmentObject(AppViewModel())
}
