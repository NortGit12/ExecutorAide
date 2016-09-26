//
//  StageViewController.swift
//  ExecutorAide
//
//  Created by Tim on 9/15/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit
import CoreData

class StageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate/*, SubTaskTableViewCellDelegate*/ {
    
    @IBOutlet weak var tableView: UITableView!
    
    var stage: Stage? {
        didSet {
            DispatchQueue.main.async {
                guard let stage = self.stage else { return }
                self.tasks = TaskModelController.shared.fetchTasks(for: stage)
            }
        }
    }
    
    var tasks: [Task]? = [] {
        didSet {
            DispatchQueue.main.async {
                guard let tasks = self.tasks else { return }
                for task in tasks {
                    let subTasks = SubTaskModelController.shared.fetchSubTasks(for: task)
                    guard let subTaskArray = subTasks else { return }
                    self.subTasks?.append(subTaskArray)
                    
                }
                self.tableView.reloadData()
            }
        }
    }
    
    var subTasks: [[SubTask]]? = []

    var fetchedResultsController: NSFetchedResultsController<Stage>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        setupCustomCells()
        setupNavbar()
    }
    
    func setupNavbar() {
        title = stage?.name
//        let titleView = navigationController?.navigationItem.titleView
        let progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: 50, height: 10))
        progressView.progressViewStyle = .bar
//        titleView?.addSubview(progressView)
        
        navigationController?.navigationItem.titleView = progressView
        
        if let percentComplete = stage?.percentComplete {
            progressView.progress = percentComplete
        }
    }
    
    func setupCustomCells() {
        // Dynamic cell height
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(UINib(nibName: "SubTaskTableViewCell", bundle: nil), forCellReuseIdentifier: subTaskCellReuseIdentifier)
    }
    
    // MARK: - TableViewDataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let tasks = tasks else { return 0 }
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let subTasks = subTasks else { return 0 }
        return subTasks[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: subTaskCellReuseIdentifier, for: indexPath) as? SubTaskTableViewCell else { return UITableViewCell() }
        let taskIndex = indexPath.section
        guard let subTask = subTasks?[taskIndex][indexPath.row] else { return UITableViewCell() }
        cell.updateCellWithSubTask(subTask: subTask)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let tasks = tasks else { return "" }
        return tasks[section].name
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func showEditing(sender: UIBarButtonItem) {
        if self.tableView.isEditing == true {
            self.tableView.isEditing = false
            self.navigationItem.rightBarButtonItem?.title = "Done"
        } else {
            self.tableView.isEditing = true
            self.navigationItem.rightBarButtonItem?.title = "Edit"
        }
    }

    // MARK: - SubTaskTableViewCellDelegate Method
    
//    func subTaskTableViewCellDidReceiveTap() -> SubTask {
//        
//    }
    
    
    
}
