//
//  TestatorViewController.swift
//  ExecutorAide
//
//  Created by Tim on 9/15/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit

class TestatorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    
    var testators = [Testator]()
    
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
            let popoverVC = segue.destination as? NewTestatorPopoverViewController
            popoverVC?.setupPopoverDisplay(containerWidth: view.frame.width, containerHeight: view.frame.height)
            let controller = popoverVC?.popoverPresentationController
            
            if let controller = controller, let sourceView = controller.sourceView {
                controller.delegate = self
                controller.backgroundColor = UIColor.lightGray
                controller.sourceRect = CGRect(x: sourceView.frame.width * 0.5, y: 0, width: 0, height: 0)
                controller.permittedArrowDirections = .down
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
