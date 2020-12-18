//
//  quizBrain.swift
//  quizapp
//
//  Created by Joshua De Matas on 2020-12-06.
//

import Foundation
import UIKit
import CoreData

class quizBrain {
    let context: NSManagedObjectContext!
    var questions: [Question]?
    var currentQuestion: Question?
    var noCorrectAnswers: Int?
    var currentQuestionIndex: Int?
    var settings: QuizSettings?
    
    var currentPlayer: Player?
    var gameResults: GameResult?
    
    init() {
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        questions = []
        
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
//        fetchQuestion(withQuestion: "How many counties in the Republic of Ireland.") { (questions) in
//            print(questions?.first?.question)
//        }
        
        settings = QuizSettings(nil, nil, nil, 1)
        
        firstLaunch()
    }
    
    func setUser(withName name: String) {
        if let user = fetchUser(withName: name)?.first {
            currentPlayer = user
            return
        }
        
        let player = Player(context: context)
        player.name = name
        player.totalScore = 0
        player.totalTried = 0
        
        saveContext()
        currentPlayer = player
    }
    
    func startGame(completion: @escaping (Bool) -> ()) {
        guard currentPlayer != nil else {
            completion(false)
            return
        }
        print("Starting game")
        
        // Empty all questions
        questions?.removeAll()
        self.gameResults = GameResult(context: context)
        self.gameResults!.user = currentPlayer
        
        fetchQuestions(with: self.settings!) { [weak self] (wasSuccessful) in
            if wasSuccessful {
                self?.currentQuestionIndex = -1
                self?.noCorrectAnswers = 0
                completion(wasSuccessful)
            } else {
                completion(wasSuccessful)
            }
        }
    }
    
    
    func endGame() -> GameResult {
        let numberOfQuestions = questions?.count
        let numberOfCorrectAnswers = noCorrectAnswers
        gameResults?.noQuestions = Int32(numberOfQuestions!)
        gameResults?.noCorrect = Int32(noCorrectAnswers!)
        gameResults?.user?.totalScore += Int32(numberOfCorrectAnswers!)
        gameResults?.user?.totalTried += Int32(numberOfQuestions!)
        
        saveContext()
        return gameResults!
    }
    
    
    /// Does the game have more questions
    func hasMoreQuestions() -> Bool {
        if questions != nil, currentQuestion != nil, currentQuestionIndex!+1 < questions!.count{
            print("\(currentQuestionIndex!+1)/\(questions!.count)")
            return true
        }
        return false
    }
    
    func resetGame() {
        currentQuestionIndex = nil
        currentQuestion = nil
        questions?.removeAll()
        questions = nil
        gameResults = nil
    }
    
    
    /// Checks the given answer to the current question in play
    func validateAnswer(_ answer: String) -> Bool {
        if currentQuestion != nil {
            if answer == currentQuestion?.correctAnswer {
                noCorrectAnswers! += 1
                let questionResult = QuestionResult(insertInto: context,
                                                    pickedAnswer: answer,
                                                    wasCorrect: true,
                                                    question: currentQuestion!)
                gameResults?.addToQuestionResults(questionResult)
                saveContext()
                return true
            }
        }
        let questionResult = QuestionResult(insertInto: context,
                                            pickedAnswer: answer,
                                            wasCorrect: false,
                                            question: currentQuestion!)
        gameResults?.addToQuestionResults(questionResult)
        saveContext()
        return false
    }
    
    /// Gets the current question
    func getQuestion() -> String? {
        return currentQuestion?.question?.htmlDecoded
    }
    
    /// Gets the current question's incorrect answers
    func getWrongAnswers() -> [String]? {
        if let wrongAnsers = currentQuestion?.incorrectAnswers as? [String] { // If there are wrong answers
            var wrongsAnswersDecoded: [String] = []
            wrongAnsers.forEach { (wrongAnswer) in // Loop through each wrong answer
                if let decodedString = wrongAnswer.htmlDecoded { // I able to decode it
                    wrongsAnswersDecoded.append(decodedString) // Append to list of wrong answers
                } else {
                    return
                }
            }
            return wrongsAnswersDecoded
        } else {
            return nil
        }
    }
    
    /// Gets the current question's correct answer
    func getRightAnswer() -> String? {
        if let decodedString = currentQuestion?.correctAnswer?.htmlDecoded {
            return decodedString
        } else {
            return nil
        }
    }
    
    /// Move to and returns the next question
    func getNextQuestion() -> Question? {
        guard currentQuestionIndex != nil, questions != nil, (currentQuestionIndex!+1) < questions!.count
        else { return nil }

        currentQuestionIndex! += 1
        currentQuestion = questions![currentQuestionIndex!]
        return currentQuestion
    }
    
}

//MARK: - Handling API Requests
extension quizBrain {
    
    func fetchQuestions(with settings: QuizSettings, completion: @escaping (Bool) -> ()) {
        print("Fetching questions")
        
        guard let url = buildApiUrl(with: settings) else {
            print("Could not build API URL")
            completion(false)
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
        print("Parsing API results")
        
        guard let results = results?.results else { return false }
        
        for i in 0..<results.count {
            // Check if question alreadying in database
            if let question = fetchQuestion(withQuestion: results[i].question)?.first {
                self.questions?.append(question)
                continue
            }
            
            // Category Setup
            // Category Attributes
            guard let category = fetchCategory(withName: results[i].category)?.first else {
                print("No such Category: \(results[i].category)")
                return false
            }
            guard let difficulty = fetchQuestionDifficulty(withName: results[i].difficulty.rawValue)?.first else {
                print("No such QuestionDifficulty: \(results[i].difficulty.rawValue))")
                return false
            }
            guard let type = fetchQuestionType(withName: results[i].type.rawValue)?.first else {
                print("No such QuestionDifficulty: \(results[i].type.rawValue))")
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
            print("Question Added")
        }
        
        return true
    }
    
    func buildApiUrl(with settings: QuizSettings) -> URL? {
        let amount = (settings.amount == nil) ? 5 : settings.amount
        let category = (settings.category == nil) ? "" : "\(settings.category!.id)"
        let diffcutly = (settings.difficulty == nil) ? "medium" : settings.difficulty.name
        let type = (settings.type == nil) ? "multiple" : settings.type.name
        
        if let url = URL(string:"https://opentdb.com/api.php?amount=\(amount!)&category=\(category)&difficulty=\(diffcutly!)&type=\(type!)") {
            print(url.absoluteURL)
            return url
        } else {
            return nil
        }
    }
}


//MARK: - Database Managing
extension quizBrain {
    /// Generic function for fetchRequets. Includes error handling and printing
    func fetchRequest<T>(with request: NSFetchRequest<T>) -> [T]? {
        do {
            return try self.context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
            return nil
        }
    }
    
    /// Fetch user by name
    func fetchUser(withName name: String) -> [Player]? {
        let request: NSFetchRequest<Player> = Player.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@", "name", "\(name)")
        
        return fetchRequest(with: request)
    }
    
    /// Fetch a category synchronously by id
    func fetchCategory(withId id: Int32) -> [Category]? {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@", "id", "\(id)")
        
        return fetchRequest(with: request)
    }
    /// Fetch a category synchronously by name
    func fetchCategory(withName name: String) -> [Category]? {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@", "name", "\(name)")
        
        return fetchRequest(with: request)
    }
    func fetchCategory(completion: @escaping ([Category]?) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            completion(self?.fetchRequest(with: Category.fetchRequest()))
        }
    }
    
    /// Fetch a QuestionDifficulty synchronously by name
    func fetchQuestionDifficulty(withName name: String) -> [QuestionDifficulty]? {
        let request: NSFetchRequest<QuestionDifficulty> = QuestionDifficulty.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@", "name", "\(name)")
        
        return fetchRequest(with: request)
    }
    func fetchQuestionDifficulty(completion: @escaping ([QuestionDifficulty]?) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            completion(self?.fetchRequest(with: QuestionDifficulty.fetchRequest()))
        }
    }
    
    
    /// Fetch a QuestionType synchronously by name
    func fetchQuestionType(withName name: String) -> [QuestionType]? {
        let request: NSFetchRequest<QuestionType> = QuestionType.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@", "name", "\(name)")
        
        return fetchRequest(with: request)
    }
    func fetchQuestionType(completion: @escaping ([QuestionType]?) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            completion(self?.fetchRequest(with: QuestionType.fetchRequest()))
        }
    }

    /// Fetch a Question synchronously by question
    func fetchQuestion(withQuestion question: String) -> [Question]? {
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@", "question", "\(question)")
        
        return fetchRequest(with: request)
    }
    /// Fetch a Question async by question
    func fetchQuestion(withQuestion question: String, completion: @escaping ([Question]?) -> ()) {
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@", "question", "\(question)")
        
        DispatchQueue.global(qos: .userInitiated).async {
            completion(self.fetchRequest(with: request))
        }
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
        if let categories = fetchRequest(with: Category.fetchRequest()) {
            print(categories.count)
            if categories.count <= 0 {
                print("Creating categories")
                createCategories()
                
            }
            
        } else {
            print("Creating categories")
            createCategories()
        }
        if let difficulties = fetchRequest(with: QuestionDifficulty.fetchRequest()) {
            if difficulties.count <= 0 {
                print("Creating difficulties")
                createDifficulties()
            }
            
        } else {
            print("Creating difficulties")
            createDifficulties()
        }
        if let types = fetchRequest(with: QuestionType.fetchRequest()) {
            if types.count <= 0 {
                print("Creating Types")
                createTypes()
            }
        } else {
            print("Creating Types")
            createTypes()
        }
        saveContext()
    }
    
    func createCategories() {
        _ = [
            Category(insertInto: context, id: 9, name: "General Knowledge"),
            Category(insertInto: context, id: 10, name: "Entertainment: Books"),
            Category(insertInto: context, id: 11, name: "Entertainment: Film"),
            Category(insertInto: context, id: 12, name: "Entertainment: Music"),
            Category(insertInto: context, id: 13, name: "Entertainment: Musicals & Theatres"),
            Category(insertInto: context, id: 14, name: "Entertainment: Television"),
            Category(insertInto: context, id: 15, name: "Entertainment: Video Games"),
            Category(insertInto: context, id: 16, name: "Entertainment: Board Games"),
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
        saveContext()
    }
    
    func createDifficulties() {
        _ = [
            QuestionDifficulty(insertInto: context, name: "easy"),
            QuestionDifficulty(insertInto: context, name: "medium"),
            QuestionDifficulty(insertInto: context, name: "hard")
        ]
        saveContext()
    }
    
    func createTypes() {
        _ = [
            QuestionType(insertInto: context, name: "multiple"),
            QuestionType(insertInto: context, name: "boolean")
        ]
        saveContext()
    }
}
