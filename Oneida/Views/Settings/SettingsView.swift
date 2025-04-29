//
//  SettingsView.swift
//  Oneida
//
//  Created by Alex on 29.04.2025.
//

import SwiftUI

struct SettingsView: View {
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
                .padding(.horizontal)
                .padding(.top)
                
                Spacer()
                
                Text("settings")
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
                
                VStack(spacing: 40) {
                    SettingRow(
                        title: "Sound Effects",
                        isOn: svm.soundIsOn,
                        action: {
                            svm.toggleSound()
                        }
                    )
                    
                    SettingRow(
                        title: "Music",
                        isOn: svm.musicIsOn,
                        isDisabled: !svm.soundIsOn,
                        action: {
                            svm.toggleMusic()
                        }
                    )
                }
                .frame(width: 300)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                        )
                )
                .opacity(settingsOpacity)
                .offset(y: settingsOffset)
                
                Spacer()
                
                Text("Version 1.0")
                    .specialFont(12, color: .white.opacity(0.7))
                    .padding(.bottom, 4)
                    .opacity(settingsOpacity)
                
                Spacer()
            }
            .padding()
        }
    }
}

struct SettingRow: View {
    let title: String
    let isOn: Bool
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .specialFont(18, color: isDisabled ? .gray : .white)
            
            Spacer()
            
            ToggleSwitch(isOn: isOn, isDisabled: isDisabled, action: action)
        }
    }
}

struct ToggleSwitch: View {
    let isOn: Bool
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Capsule()
                    .fill(isOn ? Color.green.opacity(0.8) : Color.gray.opacity(0.5))
                    .frame(width: 60, height: 30)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.7), lineWidth: 2)
                    )
                    .opacity(isDisabled ? 0.5 : 1.0)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 26, height: 26)
                    .shadow(radius: 2)
                    .offset(x: isOn ? 15 : -15)
                    .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isOn)
                    .opacity(isDisabled ? 0.5 : 1.0)
            }
        }
        .disabled(isDisabled)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppViewModel())
}
