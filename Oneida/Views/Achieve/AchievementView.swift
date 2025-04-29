//
//  AchievementView.swift
//  Oneida
//
//  Created by Alex on 29.04.2025.
//

import SwiftUI

struct AchievementView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = AchievementViewModel()
    @StateObject private var svm = SettingsViewModel.shared
    
    var body: some View {
        ZStack {
            AppBackgroundView(background: Color.deepPurple)
            
            VStack {
                // Navigation header
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
                
                // Title
                Text("Achieve")
                    .specialFont(40)
                
                // Achievement items
                VStack(spacing: 15) {
                    ForEach(viewModel.achievements) { achievement in
                        AchievementItemView(
                            achievement: achievement,
                            isCompleted: viewModel.isAchievementCompleted(achievement.id),
                            isNotified: viewModel.isAchievementNotified(achievement.id),
                            onClaim: {
                                svm.play()
                                viewModel.claimReward(for: achievement.id)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            viewModel.appViewModel = appViewModel
        }
    }
}

#Preview {
    AchievementView()
        .environmentObject(AppViewModel())
}
