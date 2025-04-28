//
//  CounterView.swift
//  Oneida
//
//  Created by Alex on 28.04.2025.
//

import SwiftUI

struct CounterView: View {
    let amount: Int
    
    var body: some View {
        Capsule()
            .frame(maxWidth: 110, maxHeight: 30)
            .foregroundStyle(Color.deepOrange)
            .overlay() {
                Capsule()
                    .stroke(lineWidth: 4)
                    .foregroundStyle(.white)
            }
            .overlay {
                Text("\(amount)")
                    .specialFont(14, color: .black)
            }
            .overlay(alignment: .leading) {
                Image(.goldCoin)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .offset(x: -15)
            }
    }
}

#Preview {
    VStack {
        CounterView(amount: 1199)
        Spacer()
    }
    .padding()
    .background(Color.deepPurple)
}
