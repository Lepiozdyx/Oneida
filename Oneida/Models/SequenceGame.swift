//
//  SequenceGame.swift
//  Oneida

import SwiftUI

enum SequenceGameConstants {
    static let initialSequenceLength = 2
    static let showImageDuration: TimeInterval = 1.5
    static let successDuration: TimeInterval = 1.5
    static let availableImages = [
        "img111", "img222", "img333", "img444",
        "img555", "img666", "img777", "img888"
    ]
}

enum SequenceGameState: Equatable {
    case showing
    case playing
    case success
    case gameOver
}

struct SequenceImage: Identifiable, Equatable {
    let id = UUID()
    let imageName: String
    
    static func random() -> SequenceImage {
        let randomIndex = Int.random(in: 0..<SequenceGameConstants.availableImages.count)
        return SequenceImage(imageName: SequenceGameConstants.availableImages[randomIndex])
    }
    
    static func == (lhs: SequenceImage, rhs: SequenceImage) -> Bool {
        return lhs.imageName == rhs.imageName
    }
}
