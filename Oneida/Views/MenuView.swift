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
        VStack {
            Spacer()
            
            Text("Oneida Games")
                .font(.largeTitle)
                .bold()
                .padding()
            
            Spacer()
            
            Button {
                svm.play()
                appViewModel.navigateTo(.levelSelect)
            } label: {
                Text("Играть")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .frame(width: 200, height: 60)
                    .background(Color.blue)
                    .cornerRadius(15)
                    .shadow(radius: 5)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    MenuView()
        .environmentObject(AppViewModel())
}
