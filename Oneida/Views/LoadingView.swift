//
//  LoadingView.swift
//  Oneida

import SwiftUI

struct LoadingView: View {
    @State private var scaleProgress: CGFloat = 0
    
    var body: some View {
        ZStack {
            AppBackgroundView(background: Color.deepPurple)
            
            VStack {
                Spacer()
                
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                
                Spacer()
                
                Text("Loading...")
                    .specialFont(20)
                
                Capsule()
                    .frame(maxWidth: 350, maxHeight: 40)
                    .foregroundStyle(Color.deepPurple)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .frame(width: 345 * scaleProgress, height: 35)
                            .foregroundStyle(Color.deepOrange)
                            .padding(.horizontal, 3)
                    }
                    .overlay() {
                        Capsule()
                            .stroke(lineWidth: 4)
                            .fill(.white)
                    }
                
                Spacer()
                
                Text("Play and to the moon!")
                    .specialFont(20)
            }
            .padding()
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5)) {
                scaleProgress = 1
            }
        }
    }
}

#Preview {
    LoadingView()
}
