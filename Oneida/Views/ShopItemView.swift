//
//  ShopItemView.swift
//  Oneida

import SwiftUI

struct ShopItemView: View {
    let imageName: String
    let price: Int
    let isPurchased: Bool
    let isSelected: Bool
    let canAfford: Bool
    let onBuy: () -> Void
    let onSelect: () -> Void
    
    @StateObject private var svm = SettingsViewModel.shared
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RadialGradient(
                    colors: [
                        Color.white,
                        Color.purple
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 60
                )
                
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.yellow : Color.white.opacity(0.7), lineWidth: isSelected ? 5 : 2)
                
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .padding(20)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
            .frame(width: 120, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: isSelected ? .yellow.opacity(0.5) : .black.opacity(0.5), radius: isSelected ? 8 : 4)
            .onAppear {
                isAnimating = true
            }
            
            Button {
                svm.play()
                if isPurchased {
                    if !isSelected {
                        onSelect()
                    }
                } else if canAfford {
                    onBuy()
                }
            } label: {
                ZStack {
                    Capsule()
                        .fill(buttonColor)
                        .frame(width: 100, height: 36)
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.7), lineWidth: 2)
                        )
                    
                    if isPurchased {
                        Text(isSelected ? "USED" : "USE")
                            .specialFont(16, color: .white)
                    } else {
                        HStack(spacing: 4) {
                            Image("goldCoin")
                                .resizable()
                                .frame(width: 20, height: 20)
                            
                            Text("\(price)")
                                .specialFont(16, color: canAfford ? .white : .gray)
                        }
                    }
                }
            }
            .disabled((isPurchased && isSelected) || (!isPurchased && !canAfford))
            .opacity((isPurchased && isSelected) || (!isPurchased && !canAfford) ? 0.6 : 1)
        }
    }
    
    private var buttonColor: Color {
        if isPurchased {
            return isSelected ? Color.green : Color.orange
        } else {
            return canAfford ? Color.orange : Color.gray
        }
    }
}

#Preview {
    ZStack {
        Color.purple.ignoresSafeArea()
        
        VStack {
            ShopItemView(
                imageName: "guitar",
                price: 0,
                isPurchased: true,
                isSelected: true,
                canAfford: true,
                onBuy: {},
                onSelect: {}
            )
            
            ShopItemView(
                imageName: "saxophone",
                price: 500,
                isPurchased: false,
                isSelected: false,
                canAfford: true,
                onBuy: {},
                onSelect: {}
            )
        }
    }
}
