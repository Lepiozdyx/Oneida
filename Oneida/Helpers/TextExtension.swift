//
//  TextExtension.swift
//  Oneida
//
//  Created by Alex on 28.04.2025.
//

import SwiftUI

extension Text {
    func specialFont(_ size: CGFloat, color: Color = .white) -> some View {
        self
            .font(.system(size: size, weight: .bold, design: .rounded))
            .foregroundStyle(color)
            .multilineTextAlignment(.center)
            .textCase(.uppercase)
    }
}

struct TextExtension: View {
    var body: some View {
        ZStack {
            AppBackgroundView(background: Color.deepPurple)
            
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .specialFont(40)
        }
    }
}

#Preview {
    TextExtension()
}
