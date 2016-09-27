//
//  TestatorViewController.swift
//  ExecutorAide
//
//  Created by Tim on 9/15/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit

class TestatorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var noTestatorsLabel: UILabel!
    
    var testators = [Testator]() {
        didSet {
            DispatchQueue.main.async {
                self.setupViewWithTestators()
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TestatorTableViewCell", bundle: nil), forCellReuseIdentifier: testatorCellReuseIdentifier)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        PersistenceController.shared.performFullSync {
            self.testators = TestatorModelController.shared.fetchTestators()!
        }
    }
    
    func setupViewWithTestators() {
        DispatchQueue.main.async {
            // Setup label
            if self.testators.isEmpty {
                self.noTestatorsLabel.isHidden = false
                self.tableView.isHidden = true
            } else {
                self.noTestatorsLabel.isHidden = true
                self.noTestatorsLabel.text = ""
                self.tableView.isHidden = false
                self.tableViewHeight.constant = CGFloat(self.testators.count * testatorCellHeight)
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - UITableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testators.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: testatorCellReuseIdentifier, for: indexPath) as? TestatorTableViewCell else { return UITableViewCell() }
        let testator = testators[indexPath.row]
        cell.updateCellWithTestator(testator: testator)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(testatorCellHeight)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toStagesSegue", sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toStagesSegue" {
            
            guard let stagesVC = segue.destination as? StageViewController, let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
            let selectedTestator = testators[selectedIndexPath.row]
            guard let stages = StageModelController.shared.fetchStages(for: selectedTestator) else { return }
            DispatchQueue.main.async {
                stagesVC.stages = stages
                stagesVC.testator = selectedTestator
            }
            
        } else if segue.identifier == "showNewTestatorPopover" {
            guard let popoverNavController = segue.destination as? UINavigationController, let popoverVC = popoverNavController.viewControllers.first as? NewTestatorPopoverViewController else { return }
            popoverVC.setupPopoverDisplay(containerWidth: self.view.frame.width, containerHeight: self.view.frame.height)
            let controller = popoverNavController.popoverPresentationController
            
            if let controller = controller {
                controller.delegate = self
                controller.backgroundColor = UIColor.lightGray
                controller.permittedArrowDirections = [.down, .up]
            }
        }
    }
    
    // MARK: - Popover VC Delegate Methods
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    
    // MARK: - IBActions
    
    @IBAction func newTestatorButtonTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "showNewTestatorPopover", sender: self)
    }
}
