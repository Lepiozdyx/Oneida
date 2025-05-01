//
//  AchievementItemView.swift
//  Oneida

import SwiftUI

struct AchievementItemView: View {
    let achievement: Achievement
    let isCompleted: Bool
    let isNotified: Bool
    let onClaim: () -> Void
    
    @State private var animate = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.orange, lineWidth: 3)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.purple.opacity(0.3))
                )
            
            HStack {
                // Trophy/medal image
                Image(achievement.imageName)
                    .resizable()
                    .frame(width: 35, height: 60)
                    .scaleEffect(animate && isCompleted && !isNotified ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: animate
                    )
                    .onAppear {
                        animate = true
                    }
                
                // Achievement info
                VStack(spacing: 15) {
                    VStack(spacing: 5){
                        Text(achievement.title)
                            .specialFont(18)
                        
                        Text(achievement.description)
                            .specialFont(10, color: .white.opacity(0.8))
                            .lineLimit(2)
                    }
                    
                    if isCompleted {
                        if isNotified {
                            Text("complete")
                                .specialFont(12, color: .yellow)
                        } else {
                            // Claim button
                            Button(action: onClaim) {
                                CounterView(amount: 10)
                                    .scaleEffect(animate ? 1.05 : 1.0)
                                    .animation(
                                        Animation.easeInOut(duration: 0.8)
                                            .repeatForever(autoreverses: true),
                                        value: animate
                                    )
                            }
                        }
                    }
                }
                .padding(.leading, 10)
            }
            .padding()
        }
        .frame(maxWidth: 350, maxHeight: 150)
    }
}

#Preview {
    let achieve = Achievement.init(id: "perfect_melody", title: "Perfect Melody", description: "Complete 3 levels in a row without making any mistakes.", imageName: "perfectMelody", reward: 10)
    
    AchievementItemView(achievement: achieve, isCompleted: true, isNotified: false, onClaim: {})
}
