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
    
    var testators = [Testator]() {
        didSet {
            tableViewHeight.constant = CGFloat(testators.count * 44)
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TestatorTableViewCell", bundle: nil), forCellReuseIdentifier: testatorCellReuseIdentifier)
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
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toStagesSegue" {
            guard let destinationVC = segue.destination as? StageViewController else { return }
            // TODO: Set first stage as default tab
        } else if segue.identifier == "showNewTestatorPopover" {
            guard let popoverNavController = segue.destination as? UINavigationController, let popoverVC = popoverNavController.viewControllers.first as? NewTestatorPopoverViewController else { return }
            popoverVC.setupPopoverDisplay(containerWidth: self.view.frame.width, containerHeight: self.view.frame.height)
            let controller = popoverNavController.popoverPresentationController
            
            if let controller = controller, let sourceView = controller.sourceView {
                controller.delegate = self
                controller.backgroundColor = UIColor.lightGray
                controller.permittedArrowDirections = [.down, .up]
                if controller.arrowDirection == .down {
                    controller.sourceRect = CGRect(x: sourceView.frame.width * 0.5, y: 0, width: 0, height: 0)
                } else if controller.arrowDirection == .up {
                    controller.sourceRect = CGRect(x: sourceView.frame.width * 0.5, y: 1000, width: 0, height: 0)
                }
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
