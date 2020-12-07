//
//  StartLaunchViewController.swift
//  quizapp
//
//  Created by Joshua De Matas on 2020-12-06.
//

import UIKit

class StartLaunchViewController: UIViewController {
    var qBrain: quizBrain!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        
        qBrain.startGame() { (wasSuccessful) in
            if wasSuccessful {
                print("Startup was sucessful. Moving to first question")
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "questionSegue", sender: self)
                }
            } else {
                print("Something went wrong... returning to start screen")
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let questionViewController = segue.destination as? QuestionViewController {
            questionViewController.qBrain = qBrain
        }
    }
}
