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
            question: "Какой инструмент традиционно считается «королем инструментов»?",
            options: ["Скрипка", "Орган", "Фортепиано", "Гитара"],
            correctOptionIndex: 1
        ),
        QuizQuestion(
            question: "Какой композитор известен как «король вальса»?",
            options: ["Фредерик Шопен", "Петр Чайковский", "Иоганн Штраус", "Вольфганг Моцарт"],
            correctOptionIndex: 2
        ),
        QuizQuestion(
            question: "Какой из этих музыкальных стилей возник в 1970-х годах?",
            options: ["Джаз", "Панк-рок", "Блюз", "Классическая музыка"],
            correctOptionIndex: 1
        ),
        QuizQuestion(
            question: "Какие ноты в музыке называют октавой?",
            options: ["5 нот", "8 нот", "10 нот", "12 нот"],
            correctOptionIndex: 1
        ),
        QuizQuestion(
            question: "Какой знак в нотной грамоте повышает звук на полтона?",
            options: ["Бемоль", "Диез", "Бекар", "Форшлаг"],
            correctOptionIndex: 1
        ),
        QuizQuestion(
            question: "Из скольки линеек состоит нотный стан?",
            options: ["3", "4", "5", "6"],
            correctOptionIndex: 2
        ),
        QuizQuestion(
            question: "Какой музыкальный инструмент является самым древним?",
            options: ["Барабан", "Флейта", "Арфа", "Лира"],
            correctOptionIndex: 1
        ),
        QuizQuestion(
            question: "Кто из этих музыкантов известен как «король рок-н-ролла»?",
            options: ["Фредди Меркьюри", "Элвис Пресли", "Майкл Джексон", "Джон Леннон"],
            correctOptionIndex: 1
        ),
        QuizQuestion(
            question: "Какой музыкальный жанр появился в США в начале 20 века в афроамериканской среде?",
            options: ["Рок", "Джаз", "Техно", "Кантри"],
            correctOptionIndex: 1
        ),
        QuizQuestion(
            question: "Какой инструмент НЕ относится к струнным?",
            options: ["Скрипка", "Виолончель", "Флейта", "Арфа"],
            correctOptionIndex: 2
        )
    ]
    
    static func getRandomQuestions(count: Int = 3) -> [QuizQuestion] {
        let shuffled = questions.shuffled()
        return Array(shuffled.prefix(min(count, questions.count)))
    }
}
