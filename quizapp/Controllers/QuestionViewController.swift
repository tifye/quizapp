//
//  QuestionViewController.swift
//  quizapp
//
//  Created by Joshua De Matas on 2020-12-06.
//

import UIKit

class QuestionViewController: UIViewController {
    var qBrain: quizBrain!
    
    // Outlets
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var AButton: UIButton!
    @IBOutlet weak var BButton: UIButton!
    @IBOutlet weak var CButton: UIButton!
    @IBOutlet weak var DButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        
        // Setup Question
        var _ = qBrain.getNextQuestion()
        questionLabel.text = qBrain.getQuestion()
        
        // Setup Buttons
        var buttons = [AButton, BButton, CButton, DButton]
        buttons.forEach { $0?.layer.cornerRadius = 5 }
        
        buttons.shuffle()
        let correctButton = buttons.removeFirst()
        
        if let correctAnswer = qBrain.getRightAnswer() {
            correctButton?.setTitle(correctAnswer, for: .normal)
        }
        if let wrongAnswers = qBrain.getWrongAnswers() {
            wrongAnswers.forEach { (wrongAnswer) in
                let button = buttons.removeFirst()
                button?.setTitle(wrongAnswer, for: .normal)
            }
        }
    }
    
    func checkAnswer(forButton button: UIButton) {
        let answer = button.title(for: .normal)
        if qBrain.validateAnswer(answer!) {
            showRightAnswerAlert(button: button)
        } else {
            showWrongAnswerAlert(button: button)
        }
    }
    
    @IBAction func answerPressed(_ sender: UIButton) {
        checkAnswer(forButton: sender)
    }
    
    private func showRightAnswerAlert(button: UIButton) {
        UIView.transition(with: button, duration: 0.3, options: [.curveLinear]) {
            button.backgroundColor = .systemGreen
        } completion: { (_) in
            let alertController = UIAlertController(title: "You're right 🥳", message: "Go on...", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(
                UIAlertAction(title: "Yes!", style: UIAlertAction.Style.default, handler: { [weak self] (_) in
                self?.goToNextScreen()
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }

    private func showWrongAnswerAlert(button: UIButton) {
        UIView.transition(with: button, duration: 0.3, options: [.transitionCrossDissolve]) {
            button.backgroundColor = .systemRed
        } completion: { (_) in
            let alertController = UIAlertController(title: "WRONG 🙈", message: "Maybe next time...", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(
                UIAlertAction(title: "Oh no...", style: UIAlertAction.Style.default, handler: { [weak self] (_) in
                self?.goToNextScreen()
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func goToNextScreen() {
        if !qBrain.hasMoreQuestions() {
            performSegue(withIdentifier: "resultsSegue", sender: self)
            return
        }
        
        guard let questionViewController = storyboard?.instantiateViewController(identifier: "questionViewController") as? QuestionViewController
        else {
            qBrain.resetGame()
            navigationController?.popToRootViewController(animated: true)
            return
        }

        questionViewController.qBrain = qBrain
        navigationController?.pushViewController(questionViewController, animated: true)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let resultsViewController = segue.destination as? ResultsViewController {
            resultsViewController.gameResults = qBrain.endGame()
        }
    }
    
    
//    private func showRightAnswerAlert(button: UIButton) {
//        haveWon = true
//        rightAnswers += 1
//        UIView.transition(with: button, duration: 1.3, options: [.curveLinear]) {
//            button.backgroundColor = .systemGreen
//        } completion: { (_) in
//            let alertController = UIAlertController(title: "You're right 🥳", message: "Go on...", preferredStyle: UIAlertController.Style.alert)
//            alertController.addAction(UIAlertAction(title: "Yes!", style: UIAlertAction.Style.default, handler: { [weak self] (_) in
//                self?.goToNextScreen()
//            }))
//            self.present(alertController, animated: true, completion: nil)
//        }
//    }
//
//    private func showWrongAnswerAlert(button: UIButton) {
//        haveWon = false
//        UIView.transition(with: button, duration: 1.3, options: [.transitionFlipFromBottom]) {
//            button.backgroundColor = .systemRed
//        } completion: { (_) in
//            let alertController = UIAlertController(title: "WRONG 🙈", message: "Maybe next time...", preferredStyle: UIAlertController.Style.alert)
//            alertController.addAction(UIAlertAction(title: "Oh no...", style: UIAlertAction.Style.default, handler: { [weak self] (_) in
//                self?.goToNextScreen()
//            }))
//            self.present(alertController, animated: true, completion: nil)
//        }
//    }
//
//    private func goToNextScreen() {
//        guard questions.isEmpty == false,
//              let questionViewController = storyboard?.instantiateViewController(withIdentifier: "QuestionViewController") as? QuestionViewController else {
//            saveGameResult()
//            performSegue(withIdentifier: "ResultView", sender: nil)
//            return
//        }
//
//        questionViewController.numberOfQuestions = numberOfQuestions
//        questionViewController.rightAnswers = rightAnswers
//        questionViewController.questions = questions
//        navigationController?.pushViewController(questionViewController, animated: true)
//    }
}
