//
//  tempQuestionModel.swift
//  quizapp
//
//  Created by Joshua De Matas on 2020-12-06.
//

import Foundation

struct TempQuestionsResult: Decodable {
    let results: [tempQuestionModel]!
}

struct tempQuestionModel: Decodable {
    
    enum QuestionType: String, Decodable {
        case multiple, boolean
    }
    
    enum Difficulty: String, Decodable {
        case easy, medium, hard
    }
    
    let category: String
    let type: QuestionType
    let difficulty: Difficulty
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
}
