//
//  TabSelectorView.swift
//  Oneida

import SwiftUI

struct TabSelectorView: View {
    @Binding var selectedTab: ShopViewModel.ShopTab
    @StateObject private var svm = SettingsViewModel.shared
    
    var body: some View {
        HStack(spacing: 20) {
            TabButton(
                title: "Instruments",
                isSelected: selectedTab == .instruments,
                action: {
                    svm.play()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = .instruments
                    }
                }
            )
            
            TabButton(
                title: "Locations",
                isSelected: selectedTab == .backgrounds,
                action: {
                    svm.play()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = .backgrounds
                    }
                }
            )
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.7), Color.orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 140, height: 40)
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? Color.yellow : Color.white.opacity(0.7),
                            lineWidth: isSelected ? 5 : 2
                        )
                )
                .shadow(
                    color: isSelected ? Color.yellow.opacity(0.5) : Color.black.opacity(0.3),
                    radius: isSelected ? 5 : 3
                )
                .overlay(
                    Text(title)
                        .specialFont(16, color: .black)
                )
                .scaleEffect(isSelected ? 1.05 : 1.0)
        }
    }
}

#Preview {
    TabSelectorView(selectedTab: .constant(.instruments))
}
