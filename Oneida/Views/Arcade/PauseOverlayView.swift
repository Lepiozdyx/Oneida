//
//  PauseOverlayView.swift
//  Oneida
//
//  Created by Alex on 28.04.2025.
//

import SwiftUI

struct PauseOverlayView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Pause")
                    .specialFont(40)
                
                Button {
                    appViewModel.resumeGame()
                } label: {
                    MainActionView(width: 200, height: 50, text: "resume", textSize: 24, textColor: .green.opacity(0.9))
                }
                
                Button {
                    appViewModel.restartLevel()
                } label: {
                    MainActionView(width: 200, height: 50, text: "restart", textSize: 24, textColor: .red)
                }
                
                Button {
                    appViewModel.goToMenu()
                } label: {
                    MainActionView(width: 200, height: 50, text: "menu", textSize: 24)
                }
            }
        }
    }
}

#Preview {
    PauseOverlayView()
        .environmentObject(AppViewModel())
}
