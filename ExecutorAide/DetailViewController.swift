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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: detailCellReuseIdentifier, for: indexPath) as? DetailTableViewCell else { return UITableViewCell() }
        
        let detail = details[indexPath.row]
        cell.updateCellWithDetail(detail: detail)
        
        return cell
    }

    
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
        
    }
    
    @IBAction func addDetailButtonTapped(_ sender: AnyObject) {
        showNewDetailAlert()
    }
    
}
