//
//  InstrumentItem.swift
//  Oneida
//

import SwiftUI

struct InstrumentItem: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let imageName: String
    let price: Int
    
    static func == (lhs: InstrumentItem, rhs: InstrumentItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    static let availableInstruments: [InstrumentItem] = [
        InstrumentItem(id: "guitar", name: "Guitar", imageName: "guitar", price: 0),
        InstrumentItem(id: "saxophone", name: "Saxophone", imageName: "saxophone", price: 100),
        InstrumentItem(id: "piano", name: "Piano", imageName: "piano", price: 100),
        InstrumentItem(id: "trumpet", name: "Trumpet", imageName: "trumpet", price: 100)
    ]
    
    static func getInstrument(id: String) -> InstrumentItem {
        return availableInstruments.first { $0.id == id } ?? availableInstruments[0]
    }
}
