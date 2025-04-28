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
    
    private let totalLevels = 15 // кол-во уровней лучше подтягивать из модели
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
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
                    
                    CounterView(amount: appViewModel.coins)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                Spacer()
                
                Text("levels")
                    .specialFont(40)
                
                Spacer()
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(1...totalLevels, id: \.self) { level in
                        LevelTileView(level: level)
                            .environmentObject(appViewModel)
                    }
                }
                .padding()
                .frame(maxWidth: 350)
                
                Spacer()
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
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(isLocked ? .gray : .green)
                .frame(width: 80, height: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white, lineWidth: 3)
                )
                .overlay(
                    Text("\(level)")
                        .specialFont(44, color: .orange)
                        .shadow(color: .black, radius: 0.8)
                )
                .overlay(alignment: .bottomTrailing) {
                    if isLocked {
                        Image(.lock)
                            .resizable()
                            .frame(width: 20, height: 30)
                            .padding(4)
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
