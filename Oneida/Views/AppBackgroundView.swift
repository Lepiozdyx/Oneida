//
//  AppBackgroundView.swift
//  Oneida
//
//  Created by Alex on 28.04.2025.
//

import SwiftUI

struct AppBackgroundView<Background: View>: View {
    let background: Background

    @State private var isVisible = false

    var body: some View {
        background
            .resizableIfNeeded()
            .ignoresSafeArea()
            .opacity(isVisible ? 1 : 0.8)
            .animation(.easeInOut(duration: 0.8), value: isVisible)
            .onAppear {
                isVisible = true
            }
    }
}

private extension View {
    func resizableIfNeeded() -> some View {
        if let image = self as? Image {
            return AnyView(image.resizable())
        } else {
            return AnyView(self)
        }
    }
}

#Preview {
//    AppBackgroundView(background: Color.deepPurple)
    AppBackgroundView(background: Image(.bg2))
}
