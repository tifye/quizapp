//
//  QuestionType+CoreDataClass.swift
//  quizapp
//
//  Created by Joshua De Matas on 2020-12-06.
//
//

import Foundation
import CoreData

@objc(QuestionType)
public class QuestionType: NSManagedObject {
    convenience public init(insertInto context: NSManagedObjectContext!, name: String) {
        let entity = NSEntityDescription.entity(forEntityName: "QuestionType", in: context)!
        self.init(entity: entity, insertInto: context)
        self.name = name
    }
}
