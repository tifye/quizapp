//
//  SettingsViewController.swift
//  quizapp
//
//  Created by Joshua De Matas on 2020-12-07.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController, NSFetchedResultsControllerDelegate {
    var qBrain : quizBrain!
    var questionDifficulties: [QuestionDifficulty]!
    var fetchedResultsController: NSFetchedResultsController<Category>!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noQuestionsGroup: UIView!
    @IBOutlet weak var noQuestionsTitleLabel: UILabel!
    @IBOutlet weak var noQuestionsLabel: UILabel!
    @IBOutlet weak var noQuestionStepper: UIStepper!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noQuestionsLabel.text = "\(qBrain.settings!.amount ?? 0)"
        noQuestionStepper.value = Double(qBrain.settings!.amount)

        noQuestionsGroup.isHidden = true
        let group = DispatchGroup()
        group.enter()
        qBrain.fetchQuestionDifficulty(completion: { (difficulties) in
            if difficulties != nil {
                self.questionDifficulties = difficulties!
                
                DispatchQueue.main.async {
                    self.noQuestionsGroup.isHidden = false
                }
                
            }
        })
        
        tableView.delegate = self
        tableView.dataSource = self
        
        initializeFetchedResultsController()
    }
    
    func initializeFetchedResultsController() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: qBrain.context,
                                                          sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
        tableView.reloadData()
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        noQuestionsLabel.text = "\(sender.value)"
        qBrain.settings?.amount = Int(sender.value)
    }
    
    @IBAction func difficultyChagned(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            qBrain.settings?.difficulty = questionDifficulties.filter { diff in
                return diff.name == "easy"
            }.first
        case 2:
            qBrain.settings?.difficulty = questionDifficulties.filter { diff in
                return diff.name == "medium"
            }.first
        case 3:
            qBrain.settings?.difficulty = questionDifficulties.filter { diff in
                return diff.name == "hard"
            }.first
        default:
            return
        }
    }
}


extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")!
        cell.textLabel?.text = fetchedResultsController.object(at: indexPath).name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        qBrain.settings?.category = fetchedResultsController.object(at: indexPath)
    }
}
