//
//  MainActionView.swift
//  Oneida

import SwiftUI

struct MainActionView: View {
    let width: CGFloat
    let height: CGFloat
    let text: String
    let textSize: CGFloat
    var textColor: Color = .white
    
    var body: some View {
        Capsule()
            .frame(maxWidth: width, maxHeight: height)
            .foregroundStyle(Color.deepOrange)
            .overlay() {
                Capsule()
                    .stroke(lineWidth: 4)
                    .fill(.gray)
            }
            .overlay {
                Text(text)
                    .specialFont(textSize, color: textColor)
            }
    }
}

#Preview {
    MainActionView(width: 250, height: 100, text: "play", textSize: 32)
}
