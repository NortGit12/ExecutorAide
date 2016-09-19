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

    var stage: Stage?
    var fetchedResultsController: NSFetchedResultsController<Stage>?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomCells()
        setupNavbar()
    }
    
    func setupNavbar() {
        title = stage?.name
        let titleView = navigationController?.navigationItem.titleView
        let progressView = UIProgressView()
        titleView?.addSubview(progressView)
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
        guard let stage = stage, let tasks = stage.tasks else { return 0 }
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let stage = stage, let tasks = stage.tasks, let task = tasks[section] as? Task, let subtasks = task.subTasks else { return 0 }
        return subtasks.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: subTaskCellReuseIdentifier, for: indexPath) as? SubTaskTableViewCell else { return UITableViewCell() }
        
        guard let subTask = stage?.tasks?[indexPath.row] as? SubTask else { return UITableViewCell() }
        cell.updateCellWithSubTask(subTask: subTask)
        
        return cell
    }
    

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let tasks = stage?.tasks, let task = tasks[section] as? Task else { return "" }
        return task.name
    }
    
    // MARK: - NSFetchedResultsController Delegate Methods
    
    func controllerWillChangeContent(controller: NSFetchedResultsController<Stage>) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController<Stage>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .automatic)
        case .insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .automatic)
        default:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController<Stage>, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .delete:
            guard let indexPath = indexPath else {return}
     
            tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
        case .insert:
            guard let newIndexPath = newIndexPath else {return}
            tableView.insertRows(at: [newIndexPath as IndexPath], with: .automatic)
        case.update:
            guard let indexPath = indexPath else {return}
            tableView.reloadRows(at: [indexPath as IndexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else {return}
            tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath as IndexPath], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController<Stage>) {
        tableView.endUpdates()
    }
    
    // MARK: - SubTaskTableViewCellDelegate Method
    
//    func subTaskTableViewCellDidReceiveTap() -> SubTask {
//        
//    }
    
    
    
}
