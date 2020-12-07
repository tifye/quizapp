//
//  SettingsViewController.swift
//  quizapp
//
//  Created by Joshua De Matas on 2020-12-07.
//

import UIKit

class SettingsViewController: UIViewController {
    var qBrain : quizBrain!
    
    
    @IBOutlet weak var noQuestionsTitleLabel: UILabel!
    @IBOutlet weak var noQuestionsLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        qBrain.settings?.amount = Int(sender.value)
    }
    
    @IBAction func difficultyChagned(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
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
