//
//  DetailViewController.swift
//  ExecutorAide
//
//  Created by Tim on 9/30/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var subTask: SubTask?
    var details: [Detail] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = subTask?.name
        
        if let subTask = subTask, let details = subTask.details {
            var detailsArray = [Detail]()
            for detail in details {
                guard let detail = detail as? Detail else { continue }
                detailsArray.append(detail)
            }
            self.details = detailsArray
        }

        // Dynamic cell height
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(UINib(nibName: "DetailTableViewCell", bundle: nil), forCellReuseIdentifier: detailCellReuseIdentifier)
    }
    
    
    // MARK: - TableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: detailCellReuseIdentifier, for: indexPath) as? DetailTableViewCell else { return UITableViewCell() }
        
        let detail = details[indexPath.row]
        cell.updateCellWithDetail(detail: detail)
        
        return cell
    }
    
    // MARK: - TableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: - Editing
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let detail = details[indexPath.row]
            // Remove from CoreData
            DetailModelController.shared.deleteDetail(detail: detail)
            // Remove locally
            self.details.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func showEditing() {
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
        
        if tableView.isEditing == true {
            // Setup navbar
            self.navigationItem.leftBarButtonItem = leftBarButtonItem
        } else {
            navigationItem.leftBarButtonItem = nil
            navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    
    func cancelButtonTapped() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem?.title = "Edit"
        tableView.isEditing = false
        setupViewForEditing()
    }
    
    // MARK: - New Detail Alert
    
    func showNewDetailAlert() {
        guard let subTask = subTask else { return }
        let alertView = UIAlertController(title: "New Detail", message: "Create a new detail for \(subTask.name)", preferredStyle: .alert)
        alertView.addTextField { (textField) in
            textField.placeholder = "Key" // TODO: Rename these placeholders
        }
        alertView.addTextField { (textField) in
            textField.placeholder = "Value"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
        let doneAction = UIAlertAction(title: "Done", style: .default) { (_) in
            guard let contentTypeString = alertView.textFields?[0].text, let contentValueString = alertView.textFields?[1].text, let numberOfDetails = subTask.details?.count else { return }
            // Create detail to be stored locally
            let newDetail = Detail(contentType: contentTypeString, contentValue: contentValueString, sortValue: numberOfDetails, subTask: subTask)!
            self.details.append(newDetail)
            DetailModelController.shared.createDetail(contentType: contentTypeString, contentValue: contentValueString, sortValue: numberOfDetails, subTask: subTask)
            self.tableView.reloadData()
        }
        
        alertView.addAction(cancelAction)
        alertView.addAction(doneAction)
        present(alertView, animated: true, completion: nil)
    }
    
    
    // MARK: - IBActions
    
    @IBAction func editButtonTapped(_ sender: AnyObject) {
        showEditing()
    }
    
    @IBAction func addDetailButtonTapped(_ sender: AnyObject) {
        showNewDetailAlert()
    }
    
}
