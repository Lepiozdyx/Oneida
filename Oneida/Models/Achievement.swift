//
//  Achievement.swift
//  Oneida

import Foundation

struct Achievement: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let imageName: String
    let reward: Int
    
    static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        return lhs.id == rhs.id
    }
    
    static let allAchievements: [Achievement] = [
        Achievement(
            id: "first_chord",
            title: "First Chord",
            description: "Catch 10 notes in a row without making a mistake.",
            imageName: "firstChord",
            reward: 10
        ),
        Achievement(
            id: "colour_symphony",
            title: "Colour Symphony",
            description: "Get through the level without missing a single note of each colour.",
            imageName: "colourSymphony",
            reward: 10
        ),
        Achievement(
            id: "perfect_melody",
            title: "Perfect Melody",
            description: "Complete 3 levels in a row without making any mistakes.",
            imageName: "perfectMelody",
            reward: 10
        ),
        Achievement(
            id: "tempo_solo",
            title: "Tempo Solo",
            description: "Try to catch 5 notes in 5 seconds.",
            imageName: "tempoSolo",
            reward: 10
        ),
        Achievement(
            id: "colour_maestro",
            title: "Colour Maestro",
            description: "Catch all the notes of the correct colour in one level.",
            imageName: "colourMaestro",
            reward: 10
        )
    ]
    
    static func byId(_ id: String) -> Achievement? {
        return allAchievements.first { $0.id == id }
    }
}
