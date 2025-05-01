//
//  ColorExtension.swift
//  Oneida

import SwiftUI

extension Color {
    static var deepPurple: LinearGradient {
        LinearGradient(
            colors: [
                Color.purple1,
                Color.purple2,
                Color.purple2
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var deepOrange: LinearGradient {
        LinearGradient(
            colors: [
                Color.orange1,
                Color.orange2
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

struct ColorExtension: View {
    var body: some View {
        ZStack {
            Color.deepPurple.ignoresSafeArea()
        }
    }
}

#Preview {
    ColorExtension()
}
