//
//  StartViewController.swift
//  quizapp
//
//  Created by Joshua De Matas on 2020-12-06.
//

import UIKit

class StartViewController: UIViewController {

    var qBrain: quizBrain!
    var quizSettings: QuizSettings!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the apps core
        qBrain = quizBrain()
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        quizSettings = QuizSettings(nil, nil, nil, 5)
        performSegue(withIdentifier: "startSegue", sender: self)
    }
    
    
     //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let startLaunchViewController = segue.destination as? StartLaunchViewController {
            startLaunchViewController.qBrain = qBrain!
            startLaunchViewController.quizSettings = quizSettings!
        }
    }
    

}
