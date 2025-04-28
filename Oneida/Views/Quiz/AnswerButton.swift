//
//  AnswerButton.swift
//  Oneida
//
//  Created by Alex on 28.04.2025.
//

import SwiftUI

struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool?
    let action: () -> Void
    
    @State private var animateWrong = false
    @State private var animateCorrect = false
    
    var body: some View {
        Button(action: action) {
            Capsule()
                .fill(backgroundColor)
                .frame(maxWidth: 250, maxHeight: 50)
                .overlay() {
                    Capsule()
                        .stroke(lineWidth: 4)
                        .fill(.gray)
                }
                .overlay {
                    Text(text)
                        .specialFont(18, color: .black)
                }
                .scaleEffect(scaleEffect)
                .rotationEffect(animateWrong ? Angle(degrees: 2) : Angle(degrees: 0))
                .offset(x: animateWrong ? -2 : 0)
                .animation(
                    isCorrect == false ? Animation.spring(response: 0.2, dampingFraction: 0.2).repeatCount(3) : .spring(),
                    value: animateWrong
                )
                .animation(
                    isCorrect == true ? Animation.spring(response: 0.3, dampingFraction: 0.6) : .spring(),
                    value: animateCorrect
                )
        }
        .shadow(radius: isSelected ? 5 : 0)
        .onChange(of: isCorrect) { _ in
            if isCorrect == false {
                animateWrong = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    animateWrong = false
                }
            }
            if isCorrect == true {
                animateCorrect = true
            }
        }
    }
    
    private var backgroundColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? .green : .red
        }
        return .orange
    }
    
    private var scaleEffect: CGFloat {
        if isCorrect == true && animateCorrect {
            return 1.05
        }
        return 1.0
    }
}

#Preview {
    AnswerButton(text: "button", isSelected: false, isCorrect: false, action: {})
        .padding()
}
