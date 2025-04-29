//
//  BackgroundItem.swift
//  Oneida
//

import SwiftUI

struct BackgroundItem: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let imageName: String
    let price: Int
    
    static func == (lhs: BackgroundItem, rhs: BackgroundItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    static let availableBackgrounds: [BackgroundItem] = [
        BackgroundItem(id: "bg2", name: "Stage", imageName: "bg2", price: 100),
        BackgroundItem(id: "bg3", name: "Concert", imageName: "bg3", price: 100),
        BackgroundItem(id: "bg4", name: "Studio", imageName: "bg4", price: 100)
    ]
    
    static func getBackground(id: String) -> BackgroundItem {
        return availableBackgrounds.first { $0.id == id } ?? availableBackgrounds[0]
    }
}
