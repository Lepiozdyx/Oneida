//
//  MusicQuiz.swift
//  Oneida
//
//  Created by Alex on 27.04.2025.
//

import Foundation

struct QuizQuestion: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctOptionIndex: Int
    
    var correctAnswer: String {
        return options[correctOptionIndex]
    }
}

struct MusicQuiz {
    static let questions = [
        QuizQuestion(
            question: "Which instrument is traditionally considered the 'king of instruments'?",
            options: ["Violin", "Organ", "Piano"],
            correctOptionIndex: 1
        ),
        QuizQuestion(
            question: "Which composer is known as the 'Waltz King'?",
            options: ["Frederic Chopin", "Pyotr Tchaikovsky", "Johann Strauss"],
            correctOptionIndex: 2
        ),
        QuizQuestion(
            question: "Which of these music genres emerged in the 1970s?",
            options: ["Jazz", "Punk rock", "Blues"],
            correctOptionIndex: 1
        ),
        QuizQuestion(
            question: "How many notes are in a musical octave?",
            options: ["5 notes", "8 notes", "10 notes"],
            correctOptionIndex: 1
        ),
        QuizQuestion(
            question: "Which symbol in musical notation raises a note by a half-step?",
            options: ["Flat", "Sharp", "Natural"],
            correctOptionIndex: 1
        ),
        QuizQuestion(
            question: "How many lines does a musical staff have?",
            options: ["3", "4", "5"],
            correctOptionIndex: 2
        ),
        QuizQuestion(
            question: "Which musical instrument is considered the oldest?",
            options: ["Drum", "Flute", "Harp"],
            correctOptionIndex: 1
        ),
        QuizQuestion(
            question: "Who among these musicians is known as the 'King of Rock and Roll'?",
            options: ["Freddie Mercury", "Elvis Presley", "Michael Jackson"],
            correctOptionIndex: 1
        ),
        QuizQuestion(
            question: "Which musical genre originated in the US in the early 20th century within African American communities?",
            options: ["Rock", "Jazz", "Techno"],
            correctOptionIndex: 1
        ),
        QuizQuestion(
            question: "Which instrument is NOT a string instrument?",
            options: ["Violin", "Cello", "Flute"],
            correctOptionIndex: 2
        )
    ]
    
    static func getRandomQuestions(count: Int = 2) -> [QuizQuestion] {
        let shuffled = questions.shuffled()
        return Array(shuffled.prefix(min(count, questions.count)))
    }
}
