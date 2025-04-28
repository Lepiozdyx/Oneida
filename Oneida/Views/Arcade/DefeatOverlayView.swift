//
//  DefeatOverlayView.swift
//  Oneida
//
//  Created by Alex on 28.04.2025.
//

import SwiftUI

struct DefeatOverlayView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("you loose")
                    .specialFont(40, color: .red)
                
                Button {
                    appViewModel.restartLevel()
                } label: {
                    MainActionView(width: 200, height: 50, text: "try again", textSize: 24)
                }
                
                Button {
                    appViewModel.goToMenu()
                } label: {
                    MainActionView(width: 200, height: 50, text: "menu", textSize: 24)
                }
            }
            .padding()
        }
    }
}

#Preview {
    DefeatOverlayView()
        .environmentObject(AppViewModel())
}
