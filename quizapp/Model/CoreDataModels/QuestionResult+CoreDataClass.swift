//
//  QuestionResult+CoreDataClass.swift
//  quizapp
//
//  Created by Joshua De Matas on 2020-12-06.
//
//

import Foundation
import CoreData

@objc(QuestionResult)
public class QuestionResult: NSManagedObject {
    convenience public init(insertInto context: NSManagedObjectContext!,
                            pickedAnswer: String, wasCorrect: Bool, question: Question) {
        let entity = NSEntityDescription.entity(forEntityName: "QuestionResult", in: context)!
        self.init(entity: entity, insertInto: context)
        
        self.pickedAnswer = pickedAnswer
        self.wasCorrect = wasCorrect
        self.gameResult = gameResult
        self.question = question
    }
}
