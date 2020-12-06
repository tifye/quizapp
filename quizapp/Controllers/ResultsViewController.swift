//
//  ResultsViewController.swift
//  quizapp
//
//  Created by Joshua De Matas on 2020-12-06.
//

import UIKit

class ResultsViewController: UIViewController {

    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var playerTotalScoreLabel: UILabel!
    @IBOutlet weak var gameScoreLabel: UILabel!
    
    @IBOutlet weak var bgImageBottom: UIImageView!
    var gameResults: GameResult!
    
    @IBOutlet weak var questionsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bgImageBottom.addBlur(0.8)
        navigationItem.hidesBackButton = true
        
        questionsTableView.delegate = self
        questionsTableView.dataSource = self
        
        playerNameLabel.text = gameResults.user?.name
        playerTotalScoreLabel.text = "\(gameResults.user?.totalScore ?? 0)/\(gameResults.user?.totalTried ?? 0)"
        gameScoreLabel.text = "\(gameResults.noCorrect)/\(gameResults.noQuestions)"
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func backToStartPressed(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension ResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameResults.questionResults?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultsReuseableCell", for: indexPath) as! ResultQuestionTableViewCell
        
        cell.setup(result: gameResults.questionResults?.allObjects[indexPath.row] as! QuestionResult)
        
        return cell
    }
    
    
}
