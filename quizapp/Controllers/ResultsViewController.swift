//
//  ResultsViewController.swift
//  quizapp
//
//  Created by Joshua De Matas on 2020-12-06.
//

import UIKit

class ResultsViewController: UIViewController {

    var gameResults: GameResult!
    
    @IBOutlet weak var questionsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        
        questionsTableView.delegate = self
        questionsTableView.dataSource = self
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
