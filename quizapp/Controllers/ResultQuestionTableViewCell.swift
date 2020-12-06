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
        containerView.clipsToBounds = true
    }

    
    func setup(result: QuestionResult) {
        questionLabel.text = result.question?.question?.htmlDecoded
        userAnswerLabel.text = result.pickedAnswer?.htmlDecoded
        correctAnswerLabel.text = result.question?.correctAnswer?.htmlDecoded
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
