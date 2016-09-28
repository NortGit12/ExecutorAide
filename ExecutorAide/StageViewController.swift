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
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var testator: Testator?
    var stages: [Stage]? {
        didSet {
            guard let stages = stages else { return }
            for i in 0...stages.count - 1 {
                segmentedControl.setTitle(stages[i].name, forSegmentAt: i)
            }
        }
        
    }
    var selectedStage: Stage?
    var tasks: [Task]? = []
    var subTasks: [[SubTask]]? = []
    
    
    
    func clearData() {
        self.tasks = []
        self.subTasks = []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        setupCustomCells()
        setupNavbar()
        reloadTableViewWithDataForSelectedStage()
        setupSegmentedControl()
        
        let rightButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.showEditing(sender:)))
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    // MARK: - Setup UI
    
    func setupSegmentedControl() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(self.reloadTableViewWithDataForSelectedStage), for: .valueChanged)
    }
    
    func setupNavbar() {
        title = selectedStage?.name
        let progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: 50, height: 10))
        progressView.progressViewStyle = .bar
//        titleView?.addSubview(progressView)
        
        navigationController?.navigationItem.titleView = progressView
        
        if let percentComplete = selectedStage?.percentComplete {
            progressView.progress = percentComplete
        }
    }
    
    func setupCustomCells() {
        // Dynamic cell height
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(UINib(nibName: "SubTaskTableViewCell", bundle: nil), forCellReuseIdentifier: subTaskCellReuseIdentifier)
    }
    
    // MARK: - Set Data
    
    func reloadTableViewWithDataForSelectedStage() {
        DispatchQueue.main.async {
            self.clearData()
            self.selectedStage = self.stages?[self.segmentedControl.selectedSegmentIndex]
            guard let stage = self.selectedStage else { return }
            self.selectedStage = stage
            let tasks = TaskModelController.shared.fetchTasks(for: stage)
            self.tasks = tasks
            guard let tasksForSelectedStage = tasks else { return }
            for task in tasksForSelectedStage {
                let subTasks = SubTaskModelController.shared.fetchSubTasks(for: task)
                guard let subTaskArray = subTasks else { return }
                self.subTasks?.append(subTaskArray)
            }
            self.tableView.reloadData()
        }
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
    
    // MARK: - Editing
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func showEditing(sender: UIBarButtonItem) {
        if tableView.isEditing == true {
            tableView.isEditing = false
            setupViewForEditing()
            navigationItem.rightBarButtonItem?.title = "Edit"
        } else {
            tableView.isEditing = true
            setupViewForEditing()
            navigationItem.rightBarButtonItem?.title = "Done"
        }
    }
    
    func setupViewForEditing() {
        let leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelButtonTapped))
        if tableView.isEditing == true {
            // Setup navbar
            self.navigationItem.leftBarButtonItem = leftBarButtonItem
            
            // Setup toolbar
            footerView.isHidden = true
            navigationController?.setToolbarHidden(false, animated: true)
            var items = [UIBarButtonItem]()
            items.append(
                UIBarButtonItem(title: "Add new", style: .plain, target: self, action: #selector(self.addNewTapped))
            )
            items.append(
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            )
            items.append(
                UIBarButtonItem(title: "Edit selected item", style: .plain, target: self, action: #selector(self.editButtonTapped))
            )
            navigationController?.toolbar.items = items
            
            // Hide tabbar
            tabBarController?.tabBar.isHidden = true
        } else {
            navigationItem.leftBarButtonItem = nil
            footerView.isHidden = false
            navigationController?.setToolbarHidden(true, animated: true)
            
            // Show tabbar
            
        }
    }
    
    func editButtonTapped() {
        print("Edit button tapped")
    }
    
    func cancelButtonTapped() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem?.title = "Edit"
        tableView.isEditing = false
        setupViewForEditing()
    }
    
    func addNewTapped() {
        let activityView = UIAlertController(title: "Add a new item", message: "", preferredStyle: .actionSheet)
        let newTaskAction = UIAlertAction(title: "New Task", style: .default) { (_) in
            self.performSegue(withIdentifier: "newTaskSegue", sender: self)
        }
        let newSubTaskAction = UIAlertAction(title: "New Subtask", style: .default) { (_) in
            self.performSegue(withIdentifier: "newSubTaskSegue", sender: self)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
        
        activityView.addAction(newTaskAction)
        activityView.addAction(newSubTaskAction)
        activityView.addAction(cancelAction)
        
        present(activityView, animated: true, completion: nil)
        
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newSubTaskSegue" {
            guard let destinationVC = segue.destination as? UINavigationController, let newSubTaskVC = destinationVC.viewControllers.first as? NewSubTaskViewController, let tasks = self.tasks else { return }
            newSubTaskVC.pickerViewDataSource = tasks
        }
    }
    
    
    // MARK: - SubTaskTableViewCellDelegate Method
    
//    func subTaskTableViewCellDidReceiveTap() -> SubTask {
//        
//    }
    
    
    
}
