//
//  MenuView.swift
//  Oneida
//
//  Created by Alex on 27.04.2025.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    var body: some View {
        ZStack {
            AppBackgroundView(background: Color.deepPurple)
            
            VStack {
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                
                Spacer()
                
                CounterView(amount: appViewModel.coins)
                
                Spacer()
                
                Button {
                    svm.play()
                    appViewModel.navigateTo(.levelSelect)
                } label: {
                    MainActionView(width: 300, height: 90, text: "play", textSize: 60)
                }
                
                Spacer()
                
                VStack(spacing: 20){
                    Button {
                        svm.play()
                        appViewModel.navigateTo(.shop)
                    } label: {
                        MainActionView(width: 200, height: 50, text: "shop", textSize: 24)
                    }
                    
                    Button {
                        svm.play()
                        appViewModel.navigateTo(.achievements)
                    } label: {
                        MainActionView(width: 200, height: 50, text: "achieve", textSize: 24)
                    }
                    
                    Button {
                        svm.play()
                        appViewModel.navigateTo(.settings)
                    } label: {
                        MainActionView(width: 200, height: 50, text: "settings", textSize: 24)
                    }
                    
                    HStack {
                        Button {
                            svm.play()
                            appViewModel.navigateTo(.miniGames)
                        } label: {
                            MainActionView(width: 50, height: 50, text: "", textSize: 24)
                                .overlay {
                                    Image(systemName: "gamecontroller")
                                        .resizable()
                                        .frame(width: 30, height: 20)
                                        .foregroundStyle(.white)
                                }
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: 300)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    MenuView()
        .environmentObject(AppViewModel())
}
