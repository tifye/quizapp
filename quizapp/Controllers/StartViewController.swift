//
//  StartViewController.swift
//  quizapp
//
//  Created by Joshua De Matas on 2020-12-06.
//

import UIKit

class StartViewController: UIViewController {

    var quizBrain: quizBrain!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the apps core
        quizBrain = quizBrain()
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        let settings = QuizSettings(nil, nil, nil, 5)
        quizBrain.fetchQuestions(with: settings) { (success) in
            if success {
                print("Could Fetch Questions")
            } else {
                print("Could not Fetch Questions")
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
