//
//  QuizSettingsModel.swift
//  quizapp
//
//  Created by Joshua De Matas on 2020-12-06.
//

import Foundation

struct QuizSettings {
    let difficulty: QuestionDifficulty!
    let amount: Int!
    let type: QuestionType!
    let category: Category?
    
    init(_ difficulty: QuestionDifficulty?, _ type: QuestionType?, _ category: Category?, _ amount: Int?) {
        self.difficulty = difficulty
        self.type = type
        self.category = category
        self.amount = amount
    }
    
}
