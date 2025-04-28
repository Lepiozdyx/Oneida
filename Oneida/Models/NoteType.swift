//
//  NoteType.swift
//  Oneida
//
//  Created by Alex on 27.04.2025.
//

import SwiftUI

enum NoteType: Int, CaseIterable, Identifiable {
    case key = 0
    case note1
    case note2
    case note3
    case note4
    case note5
    
    var id: Int { self.rawValue }
    
    var imageResource: ImageResource {
        switch self {
        case .key: return .key
        case .note1: return .note1
        case .note2: return .note2
        case .note3: return .note3
        case .note4: return .note4
        case .note5: return .note5
        }
    }
    
    var imageName: String {
        switch self {
        case .key: return "key"
        case .note1: return "note1"
        case .note2: return "note2"
        case .note3: return "note3"
        case .note4: return "note4"
        case .note5: return "note5"
        }
    }
    
    var color: Color {
        switch self {
        case .key: return .white
        case .note1: return .red
        case .note2: return .green
        case .note3: return .blue
        case .note4: return .yellow
        case .note5: return .purple
        }
    }
    
    var points: Int {
        return 1
    }
    
    static func random(excludingKey: Bool = true) -> NoteType {
        let cases = excludingKey ?
        NoteType.allCases.filter({ $0 != .key }) :
        NoteType.allCases
        
        let randomIndex = Int.random(in: 0..<cases.count)
        return cases[randomIndex]
    }
}
