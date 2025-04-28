//
//  MainActionView.swift
//  Oneida
//
//  Created by Alex on 28.04.2025.
//

import SwiftUI

struct MainActionView: View {
    let width: CGFloat
    let height: CGFloat
    let text: String
    let textSize: CGFloat
    
    var body: some View {
        Capsule()
            .frame(maxWidth: width, maxHeight: height)
            .foregroundStyle(Color.deepOrange)
            .overlay() {
                Capsule()
                    .stroke(lineWidth: 4)
                    .foregroundStyle(.gray)
            }
            .overlay {
                Text(text)
                    .specialFont(textSize)
            }
    }
}

#Preview {
    MainActionView(width: 250, height: 100, text: "play", textSize: 32)
}
