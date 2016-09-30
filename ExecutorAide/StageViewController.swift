//
//  StageViewController.swift
//  ExecutorAide
//
//  Created by Tim on 9/15/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit
import CoreData

class StageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var segmentedControl: CustomSegmentedControl!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var progressView: UIProgressView!
    
    var testator: Testator?
    var stages: [Stage]? {
        didSet {
            guard let stages = stages else { return }
            let stageNames = stages.flatMap { $0.name }
            segmentedControl.items = stageNames
        }
        
    }
    var selectedStage: Stage?
    var tasks: [Task]? = []
    var subTasks: [[SubTask]]? = []
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        setupCustomCells()
        reloadViewWithDataForSelectedStage()
        setupSegmentedControl()
        
        let rightButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.showEditing(sender:)))
        self.navigationItem.rightBarButtonItem = rightButton
        
        let nib = UINib(nibName: "CustomSectionHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: customSectionHeaderReuseIdentifier)
    }
    
    // MARK: - Setup UI
    
    func setupSegmentedControl() {
        segmentedControl.selectedIndex = 0
        segmentedControl.addTarget(self, action: #selector(self.reloadViewWithDataForSelectedStage), for: .valueChanged)
    }
    
    func updateNavbar() {
        navigationItem.title = selectedStage?.name
        guard let percentComplete = selectedStage?.percentComplete else { return }
        navigationItem.prompt = "\(percentComplete)% complete"
        let progressBarContainerView = UIView(frame: CGRect(x: view.frame.width/2, y: 0, width: view.frame.width/2, height: 10))
        progressBarContainerView.backgroundColor = .clear
        progressBarContainerView.layer.borderColor = UIColor.darkGray.cgColor
        progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: progressBarContainerView.frame.width, height: progressBarContainerView.frame.height))
        progressBarContainerView.addSubview(progressView)
        updateProgressView()
        navigationItem.titleView = progressBarContainerView
    }
    
    func updateProgressView() {
        DispatchQueue.main.async {
            let percentComplete = self.calculatePercentComplete()
            self.progressView.progress = percentComplete
            self.navigationItem.prompt = "\(Int(percentComplete * 100))% complete"
        }
    }
    
    func calculatePercentComplete() -> Float {
        guard let subTasks = subTasks else { return 0.0 }
        let allSubTasks = subTasks.flatMap { $0 }
        var completedSubTaskCount = 0
        for subTask in allSubTasks {
            if subTask.isCompleted {
                completedSubTaskCount += 1
            }
        }
        if allSubTasks.count == 0 {
            return 0
        } else {
            return (Float(completedSubTaskCount)/Float(allSubTasks.count))
        }
    }
    
    func setupCustomCells() {
        // Dynamic cell height
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(UINib(nibName: "SubTaskTableViewCell", bundle: nil), forCellReuseIdentifier: subTaskCellReuseIdentifier)
    }
    
    func displayDeleteWarning(forTask task: Task) {
        let alertView = UIAlertController(title: "Delete Task?", message: "Are you sure you want to delete this task and all it's subtasks? This cannot be undone.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
        let okAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            // Remove from tableView datasource
            let taskIndex = task.sortValue
            self.tasks?.remove(at: taskIndex)
            // Remove from CoreData
            guard let tasks = self.tasks, let subTasks = self.subTasks?[taskIndex] else { return }
            
            TaskModelController.shared.deleteTask(task: task) {
                self.resetTaskArraySortValues(tasks: tasks, completion: { 
                    // Animate deletion
                    DispatchQueue.main.async {
                        if subTasks.isEmpty {
                            // Crash occurs if deleteSections(_:_:) is called on a section with no rows
                            self.tableView.reloadData()
                        } else {
                            let indexSet = IndexSet(integer: taskIndex)
                            self.tableView.deleteSections(indexSet, with: .fade)
                        }
                        self.updateProgressView()
                    }
                })
            }
        }
        alertView.addAction(cancelAction)
        alertView.addAction(okAction)
        present(alertView, animated: true, completion: nil)
    }
    
    // MARK: - Set TableView Data
    
    func reloadViewWithDataForSelectedStage() {
        DispatchQueue.main.async {
            self.clearData()
            self.selectedStage = self.stages?[self.segmentedControl.selectedIndex]
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
            self.updateNavbar()
        }
    }
    
    func clearData() {
        self.tasks = []
        self.subTasks = []
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
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetailSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let tasks = tasks else { return "" }
        return tasks[section].name
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let tasks = tasks else { return UIView() }
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: customSectionHeaderReuseIdentifier) as? CustomSectionHeader else { return nil }
        headerView.delegate = self
        headerView.task = tasks[section]
        headerView.updateHeaderWithTaskInfo()
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    // MARK: - Editing
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let task = self.tasks?[sourceIndexPath.section] else { return }
        // Move subTask in VC dataSource
        let section = sourceIndexPath.section
        guard let subTaskToMove = subTasks?[section][sourceIndexPath.row] else { return }
        subTasks?[section].remove(at: sourceIndexPath.row)
        subTasks?[section].insert(subTaskToMove, at: destinationIndexPath.row)
        
        // Update CoreData data source
        self.subTaskArrayDidChangeOrder(inTask: task)
    }
    
    // Prevent user from trying to move row to a different section
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            var row = 0
            if sourceIndexPath.section < proposedDestinationIndexPath.section {
                row = self.tableView(tableView, numberOfRowsInSection: sourceIndexPath.section) - 1
            }
            return IndexPath(row: row, section: sourceIndexPath.section)
        }
        return proposedDestinationIndexPath
    }
    
    func showEditing(sender: UIBarButtonItem) {
        tableView.isEditing = !tableView.isEditing
        if tableView.isEditing == true {
            setupViewForEditing()
            navigationItem.rightBarButtonItem?.title = "Done"
            navigationItem.rightBarButtonItem?.style = .done
        } else {
            setupViewForEditing()
            navigationItem.rightBarButtonItem?.title = "Edit"
        }
    }
    
    func setupViewForEditing() {
        // Setup bar buttons
        let leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelButtonTapped))
        
        // Setup section header views
        if let tasks = tasks {
            if !tasks.isEmpty {
                for i in 0...tasks.count - 1 {
                    guard let customSectionHeaderView = tableView.headerView(forSection: i) as? CustomSectionHeader else { return }
                    customSectionHeaderView.deleteButton.isHidden = !tableView.isEditing
                }
            }
        }
        
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
            newSubTaskVC.delegate = self
        } else if segue.identifier == "newTaskSegue" {
            guard let destinationVC = segue.destination as? UINavigationController, let newTaskVC = destinationVC.viewControllers.first as? NewTaskViewController, let selectedStage = selectedStage else { return }
            newTaskVC.stage = selectedStage
            newTaskVC.delegate = self
        } else if segue.identifier == "showDetailSegue" {
            guard let destinationVC = segue.destination as? DetailViewController, let selectedIndexPath = tableView.indexPathForSelectedRow, let subTasksArray = self.subTasks else { return }
            let section = selectedIndexPath.section
            let subTasks = subTasksArray[section]
            let subTask = subTasks[selectedIndexPath.row]
            destinationVC.subTask = subTask
        }
    }
    
    // MARK: - Helper Functions
    
    func subTaskArrayDidChangeOrder(inTask task: Task) {
        let moc = Stack.shared.managedObjectContext
        moc.performAndWait {
            guard let subTasks = self.subTasks?[task.sortValue] else { return }
            for subTask in subTasks {
                guard let newSubTaskSortValue = subTasks.index(of: subTask) else { continue }
                subTask.sortValue = newSubTaskSortValue
                SubTaskModelController.shared.updateSubTask(subTask: subTask)
            }
        }
    }
    
    func resetTaskArraySortValues(tasks: [Task], completion: @escaping () -> Void) {
        // for each task, reset the sort value to it's place in the array
        let moc = Stack.shared.managedObjectContext
        moc.performAndWait {
            
            for task in tasks {
                guard let taskIndex = tasks.index(of: task) else { continue }
                task.sortValue = Int(taskIndex)
                TaskModelController.shared.updateTask(task: task, completion: { 
                    completion()
                })
            }
        }
    }
}


extension StageViewController: NewElementDelegate {
    func stageWillUpdateWithNewData() {
        reloadViewWithDataForSelectedStage()
        setupViewForEditing()
        updateProgressView()
    }
}

extension StageViewController: SectionHeaderDelegate {
    func didTapDeleteSectionButton(withTask task: Task) {
        displayDeleteWarning(forTask: task)
        
    }
}

extension StageViewController: SubTaskTableViewCellDelegate {
    func subTaskTableViewCellDidChangeCompletionState(sender: SubTaskTableViewCell) {
        if let indexPath = tableView.indexPath(for: sender), let subTasks = self.subTasks {
            let subTask = subTasks[indexPath.section][indexPath.row]
            // Update dataSource
            subTask.isCompleted = !subTask.isCompleted
            sender.updateCellWithSubTask(subTask: subTask)
            updateProgressView()
            SubTaskModelController.shared.updateSubTask(subTask: subTask)
        }
    }
}
