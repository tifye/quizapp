//
//  quizBrain.swift
//  quizapp
//
//  Created by Joshua De Matas on 2020-12-06.
//

import Foundation
import UIKit
import CoreData

class QuizBrain {
    let context: NSManagedObjectContext!
    var questions: [Question]?
    var currentQuestion: Question?
    
    init() {
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        questions = []        
    }
    
}

//MARK: - Handling API Requests
extension QuizBrain {

    
    func fetchQuestions(with settings: QuizSettings, completion: @escaping (Bool) -> ()) {
        // Empty all questions
        questions?.removeAll()
        
        guard let url = buildApiUrl(with: settings) else {
            print("Could not build API URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, _, error) in
            guard let data = data else {
                print(error!)
                return
            }
            //print(String(data: data, encoding: .utf8))
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let questionsResult = try? decoder.decode(TempQuestionsResult.self, from: data)
            completion(self?.parseApiResults(questionsResult) ?? false)
        }
        task.resume()
    }
    
    func parseApiResults(_ results: TempQuestionsResult?) -> Bool {
        guard let results = results?.results else { return false }
        
        for i in 0..<results.count {
            // Check if question alreadying in database
            if let question = fetchQuestionSync(withQuestion: results[1].question)?.first {
                self.questions?.append(question)
                continue
            }
            
            // Category Setup
            // Category Attributes
            guard let category = fetchCategorySync(withName: results[1].category)?.first else {
                print("No such Category: \(results[1].category)")
                return false
            }
            guard let difficulty = fetchQuestionDifficultySync(withName: results[0].difficulty.rawValue)?.first else {
                print("No such QuestionDifficulty: \(results[0].difficulty.rawValue))")
                return false
            }
            guard let type = fetchQuestionTypeSync(withName: results[0].type.rawValue)?.first else {
                print("No such QuestionDifficulty: \(results[0].type.rawValue))")
                return false
            }
            
            // Question Setup
            // Question Attributes
            let question = Question(context: context)
            question.correctAnswer = results[i].correctAnswer
            question.incorrectAnswers = results[i].incorrectAnswers as NSArray
            question.question = results[i].question
            // Question Relationships
            question.category = category
            question.difficulty = difficulty
            question.type = type
            
            // Setup other
            category.addToQuestions(question)
            difficulty.addToQuestions(question)
            type.addToQuestions(question)
            
            
            saveContext()
            questions?.append(question)
        }
        
        return true
    }
    
    func buildApiUrl(with settings: QuizSettings) -> URL? {
        let amount = (settings.amount == nil) ? 5 : settings.amount
        let category = (settings.category == nil) ? "" : settings.category?.name
        let diffcutly = (settings.difficulty == nil) ? "medium" : settings.difficulty.name
        let type = (settings.type == nil) ? "multiple" : settings.type.name
        
        if let url = URL(string:"https://opentdb.com/api.php?amount=\(amount!)&category=\(category!)&difficulty=\(diffcutly!)&type=\(type!)") {
            print(url.absoluteURL)
            return url
        } else {
            return nil
        }
    }
}


//MARK: - Database Managing
extension QuizBrain {
    /// Generic function for fetchRequets. Includes error handling and printing
    func fetchRequest<T>(with request: NSFetchRequest<T>) -> [T]? {
        do {
            return try self.context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
            return nil
        }
    }
    
    /// Fetch a category synchronously by id
    func fetchCategorySync(withId id: Int32) -> [Category]? {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@", "id", "\(id)")
        
        return fetchRequest(with: request)
    }
    /// Fetch a category synchronously by name
    func fetchCategorySync(withName name: String) -> [Category]? {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@", "name", "\(name)")
        
        return fetchRequest(with: request)
    }
    /// Fetch a QuestionDifficulty synchronously by name
    func fetchQuestionDifficultySync(withName name: String) -> [QuestionDifficulty]? {
        let request: NSFetchRequest<QuestionDifficulty> = QuestionDifficulty.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@", "name", "\(name)")
        
        return fetchRequest(with: request)
    }
    /// Fetch a QuestionType synchronously by name
    func fetchQuestionTypeSync(withName name: String) -> [QuestionType]? {
        let request: NSFetchRequest<QuestionType> = QuestionType.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@", "name", "\(name)")
        
        return fetchRequest(with: request)
    }
    /// Fetch a Question by question
    func fetchQuestionSync(withQuestion question: String) -> [Question]? {
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@", "question", "\(question)")
        
        return fetchRequest(with: request)
    }
    
    
    /// Saves the current context
    func saveContext () {
        if context.hasChanges {
            do {
                try self.context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //MARK: - First Launch
    /// Database first initialize with Categories, Types and Difficulties
    func firstLaunch() {
        let categories = [
            Category(insertInto: context, id: 9, name: "General Knowledge"),
            Category(insertInto: context, id: 10, name: "EnterTainment: Books"),
            Category(insertInto: context, id: 11, name: "EnterTainment: Film"),
            Category(insertInto: context, id: 12, name: "EnterTainment: Music"),
            Category(insertInto: context, id: 13, name: "EnterTainment: Musicals & Theatres"),
            Category(insertInto: context, id: 14, name: "EnterTainment: Television"),
            Category(insertInto: context, id: 15, name: "EnterTainment: Video Games"),
            Category(insertInto: context, id: 16, name: "EnterTainment: Board Games"),
            Category(insertInto: context, id: 17, name: "Science & Nature"),
            Category(insertInto: context, id: 18, name: "Science: Video Games"),
            Category(insertInto: context, id: 19, name: "Science: Mathematics"),
            Category(insertInto: context, id: 20, name: "Mythology"),
            Category(insertInto: context, id: 21, name: "Sports"),
            Category(insertInto: context, id: 22, name: "Geography"),
            Category(insertInto: context, id: 23, name: "History"),
            Category(insertInto: context, id: 24, name: "Politics"),
            Category(insertInto: context, id: 25, name: "Art"),
            Category(insertInto: context, id: 26, name: "Celebrities"),
            Category(insertInto: context, id: 27, name: "Animals"),
            Category(insertInto: context, id: 28, name: "Vehicles"),
            Category(insertInto: context, id: 29, name: "Entertainment: Comics"),
            Category(insertInto: context, id: 30, name: "Science: Gadgets"),
            Category(insertInto: context, id: 31, name: "Entertainment: Japanese Anime & Manga"),
            Category(insertInto: context, id: 32, name: "Entertainment: Cartoon & Animations")
        ]
        
        let difficulties = [
            QuestionDifficulty(insertInto: context, name: "easy"),
            QuestionDifficulty(insertInto: context, name: "medium"),
            QuestionDifficulty(insertInto: context, name: "hard")
        ]
        
        let types = [
            QuestionType(insertInto: context, name: "multiple"),
            QuestionType(insertInto: context, name: "boolean")
        ]
        
        saveContext()
    }
}
