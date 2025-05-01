//
//  QuizResultView.swift
//  Oneida

import SwiftUI

struct QuizResultView: View {
    let earnedCoins: Int
    @State private var showAnimation = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text("You win")
                .specialFont(18)
            
            CounterView(amount: earnedCoins)
                .scaleEffect(showAnimation ? 1 : 0.3)
                .shadow(color: .yellow, radius: showAnimation ? 15 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.5), value: showAnimation)
                .onAppear {
                    showAnimation = true
                }
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white, lineWidth: 2)
        )
    }
}

#Preview {
    ZStack {
        AppBackgroundView(background: Color.deepPurple)
        
        QuizResultView(earnedCoins: 20)
    }
}
