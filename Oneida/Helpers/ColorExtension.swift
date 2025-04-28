//
//  ColorExtension.swift
//  Oneida
//
//  Created by Alex on 28.04.2025.
//

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
    
//    static var deepGreen: RadialGradient {
//        RadialGradient(
//            colors: [
//                Color.white,
//                Color.green
//            ],
//            center: .center,
//            startRadius: 0,
//            endRadius: 40
//        )
//    }
//    
//    static var deepRed: RadialGradient {
//        RadialGradient(
//            colors: [
//                Color.white,
//                Color.red
//            ],
//            center: .center,
//            startRadius: 0,
//            endRadius: 40
//        )
//    }
}

struct ColorExtension: View {
    var body: some View {
        ZStack {
            Color.deepPurple.ignoresSafeArea()
            
//            VStack {
//                Rectangle()
//                    .fill(Color.deepGreen)
//                    .frame(width: 80, height: 80)
//                    .cornerRadius(10)
//                
//                Rectangle()
//                    .fill(Color.deepRed)
//                    .frame(width: 80, height: 80)
//                    .cornerRadius(10)
//            }
        }
    }
}

#Preview {
    ColorExtension()
}
