//
//  SequenceGameView.swift
//  Oneida

import SwiftUI

struct SequenceGameView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = SequenceGameViewModel()
    @StateObject private var svm = SettingsViewModel.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AppBackgroundView(background: Color.deepPurple)
                
                VStack {
                    HStack {
                        Button {
                            svm.play()
                            appViewModel.navigateTo(.miniGames)
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
                        
                        ZStack {
                            Capsule()
                                .fill(Color.deepOrange)
                                .frame(width: 150, height: 40)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white, lineWidth: 2)
                                )
                            
                            Text("Combination: \(viewModel.currentSequenceLength)")
                                .specialFont(16)
                        }
                    }
                    
                    Text("Repeat the sequence")
                        .specialFont(30)
                        .padding(.vertical)
                    
                    Spacer()
                    
                    VStack(spacing: 40) {
                        Image(.tile2)
                            .resizable()
                            .frame(width: 150, height: 150)
                            .overlay {
                                if let currentImage = viewModel.currentShowingImage {
                                    Image(currentImage.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .padding()
                                        .transition(.scale.combined(with: .opacity))
                                        .id("currentImage-\(currentImage.id)")
                                } else if viewModel.gameState == .playing {
                                    Image(.tile)
                                        .resizable()
                                        .frame(width: 150, height: 150)
                                }
                            }
                            .padding(.top)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(SequenceGameConstants.availableImages, id: \.self) { imageName in
                                SequenceImageButton(
                                    imageName: imageName,
                                    onTap: {
                                        svm.play()
                                        viewModel.selectImage(SequenceImage(imageName: imageName))
                                    },
                                    disabled: viewModel.gameState != .playing
                                )
                            }
                        }
                        .frame(maxWidth: 350)
                    }
                    .padding()
                    .background(
                        Image(.frame)
                            .resizable()
                    )
                    
                    Spacer()
                }
                .padding()
                
                if viewModel.gameState == .gameOver {
                    gameOverOverlay
                }
                
                if viewModel.gameState == .success {
                    successOverlay
                }
            }
        }
    }
    
    private struct SequenceImageButton: View {
        let imageName: String
        let onTap: () -> Void
        let disabled: Bool
        
        var body: some View {
            Button(action: onTap) {
                ZStack {
                    Image(.tile2)
                        .resizable()
                    
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                }
                .frame(width: 90, height: 90)
                .opacity(disabled ? 0.6 : 1.0)
            }
            .disabled(disabled)
        }
    }
    
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Success!")
                    .specialFont(40, color: .green)
                
                Text("Congratulations!")
                    .specialFont(16)
                
                Button {
                    svm.play()
                    viewModel.nextRound()
                } label: {
                    MainActionView(width: 200, height: 50, text: "Continue", textSize: 24)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.deepPurple)
                    .opacity(0.9)
                    .shadow(radius: 10)
            )
        }
    }
    
    private var gameOverOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Game Over")
                    .specialFont(40, color: .red)
                
                Text("You made a mistake in the sequence.")
                    .specialFont(16)
                
                Button {
                    svm.play()
                    viewModel.restartAfterGameOver()
                } label: {
                    MainActionView(width: 200, height: 50, text: "Try Again", textSize: 24)
                }
                
                Button {
                    svm.play()
                    appViewModel.navigateTo(.miniGames)
                } label: {
                    MainActionView(width: 200, height: 50, text: "Back to Menu", textSize: 24)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.deepPurple)
                    .opacity(0.9)
                    .shadow(radius: 10)
            )
        }
    }
}

#Preview {
    SequenceGameView()
        .environmentObject(AppViewModel())
}
