//
//  Category+CoreDataClass.swift
//  quizapp
//
//  Created by Joshua De Matas on 2020-12-06.
//
//

import Foundation
import CoreData

@objc(Category)
public class Category: NSManagedObject {
    convenience public init(insertInto context: NSManagedObjectContext!, id: Int, name: String) {
        let entity = NSEntityDescription.entity(forEntityName: "Category", in: context)!
        self.init(entity: entity, insertInto: context)
        self.name = name
        self.id = Int32(id)
    }
}
