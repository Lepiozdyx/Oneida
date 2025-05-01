//
//  MemoryCardView.swift
//  Oneida

import SwiftUI

struct MemoryCardView: View {
    let card: MemoryCard
    let onTap: () -> Void
    let isInteractionDisabled: Bool
    
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    @State private var flipped: Bool = false
    
    var body: some View {
        Button {
            onTap()
        } label: {
            ZStack {
                // Card back (when face down)
                Image(.tile)
                    .resizable()
                    .opacity(rotation < 90 ? 1.0 : 0.0)
                
                // Card front (when face up)
                if let cardImage = MemoryCardImage(rawValue: card.imageIdentifier) {
                    Image(.tile2)
                        .resizable()
                        .opacity(rotation >= 90 ? 1.0 : 0.0)
                        .overlay(
                            Image(cardImage.imageName)
                                .resizable()
                                .scaledToFit()
                                .padding(15)
                                .opacity(rotation >= 90 ? 1.0 : 0.0)
                        )
                }
            }
            .scaleEffect(scale)
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: 0.0, y: 1.0, z: 0.0)
            )
        }
        .buttonStyle(.plain)
        .disabled(isInteractionDisabled)
        .onAppear {
            flipped = card.state != .faceDown
            rotation = flipped ? 180 : 0
            scale = card.state == .matched ? 0.9 : 1.0
        }
        .onChange(of: card.state) { newState in
            switch newState {
            case .faceDown:
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    rotation = 0
                    flipped = false
                }
            case .faceUp:
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    rotation = 180
                    flipped = true
                }
            case .matched:
                withAnimation(.easeInOut(duration: 0.3)) {
                    rotation = 180
                    flipped = true
                    scale = 0.9
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.deepPurple.ignoresSafeArea()
        
        HStack(spacing: 10) {
            MemoryCardView(
                card: MemoryCard(
                    imageIdentifier: 1,
                    state: .faceDown,
                    position: .init(row: 0, column: 0)
                ),
                onTap: {},
                isInteractionDisabled: false
            )
            .frame(width: 80, height: 80)
            
            MemoryCardView(
                card: MemoryCard(
                    imageIdentifier: 1,
                    state: .faceUp,
                    position: .init(row: 0, column: 1)
                ),
                onTap: {},
                isInteractionDisabled: false
            )
            .frame(width: 80, height: 80)
            
            MemoryCardView(
                card: MemoryCard(
                    imageIdentifier: 2,
                    state: .matched,
                    position: .init(row: 0, column: 2)
                ),
                onTap: {},
                isInteractionDisabled: true
            )
            .frame(width: 80, height: 80)
        }
    }
}
