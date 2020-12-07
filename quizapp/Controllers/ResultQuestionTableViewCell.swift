//
//  ResultQuestionTableViewCell.swift
//  quizapp
//
//  Created by Joshua De Matas on 2020-12-06.
//

import UIKit

class ResultQuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var userAnswerLabel: UILabel!
    @IBOutlet weak var correctAnswerLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        containerView.layer.cornerRadius = 5
        containerView.addShadowAndRoundedCorners()
        
        correctAnswerLabel.layer.cornerRadius = correctAnswerLabel.bounds.height/2
        correctAnswerLabel.clipsToBounds = true
        userAnswerLabel.layer.cornerRadius = userAnswerLabel.bounds.height/2
        userAnswerLabel.clipsToBounds = true
    }

    
    func setup(result: QuestionResult) {
        questionLabel.text = result.question?.question?.htmlDecoded
        userAnswerLabel.text = " You: \(result.pickedAnswer!.htmlDecoded!)"
        correctAnswerLabel.text = " Answer: \(result.question!.correctAnswer!.htmlDecoded!)"
        
        correctAnswerLabel.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        if result.wasCorrect {
            userAnswerLabel.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        } else {
            userAnswerLabel.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
