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
    
    @IBOutlet weak var playernameLabel: UILabel!
    @IBOutlet weak var playerScore: UILabel!
    @IBOutlet weak var bgImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the apps core
        qBrain = quizBrain()
        
        if let username = UserDefaults.standard.string(forKey: "Username") {
            setUser(withName: username)
        } else if let user = qBrain.currentPlayer {
            setUser(withName: user.name!)
        }
        
        bgImage.addBlur(0.5)
        
        
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
    
    func setUser(withName name: String) {
        qBrain.setUser(withName: name)
        playernameLabel.text = qBrain.currentPlayer?.name
        playerScore.text = "\(qBrain.currentPlayer!.totalScore)/\(qBrain.currentPlayer!.totalTried)"
        UserDefaults.standard.setValue(name, forKey: "Username")
    }
    
    @IBAction func newUser(_ sender: Any) {
        let alert = UIAlertController(title: "Playname", message: "Pick a name", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "AwesomeQuizzer1337"
        }
        
        alert.addAction(UIAlertAction(title: "Set", style: .default, handler: { (handler) in
            let textField = alert.textFields![0]
            self.setUser(withName: textField.text!)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
