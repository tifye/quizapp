//
//  StartLaunchViewController.swift
//  quizapp
//
//  Created by Joshua De Matas on 2020-12-06.
//

import UIKit

class StartLaunchViewController: UIViewController {
    var quizbrain: quizBrain!
    var quizSettings: QuizSettings!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        
        quizbrain.startGame(with: quizSettings) { (wasSuccessful) in
            if wasSuccessful {
                print("Startup was sucessful. Moving to first question")
                
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "questionSegue", sender: self)
                }
            } else {
                print("Something went wrong... returning to start screen")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let questionViewController = segue.destination as? QuestionViewController {
            questionViewController.quizBrain = quizbrain
        }
    }
}
