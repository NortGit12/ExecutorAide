//
//  NewTestatorPopoverViewController.swift
//  ExecutorAide
//
//  Created by Tim on 9/15/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit

class NewTestatorPopoverViewController: UIViewController {

    @IBOutlet weak var testatorNameTextField: UITextField!
    
    var testatorImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewDidLayoutSubviews() {
        setupTextField()
    }
    
    func setupPopoverDisplay(containerWidth: CGFloat, containerHeight: CGFloat) {
        self.view.backgroundColor = UIColor.lightGray
        self.preferredContentSize = CGSize(width: containerWidth/2, height: containerHeight/2)
    }
    
    func setupTextField() {
        testatorNameTextField.borderStyle = .none
        
        
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: testatorNameTextField.frame.size.height - width, width: testatorNameTextField.frame.size.width, height: testatorNameTextField.frame.size.height)
        
        border.borderWidth = width
        testatorNameTextField.layer.addSublayer(border)
        testatorNameTextField.layer.masksToBounds = true
    }
    
    
    // MARK: - IBActions
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        guard let testatorImage = testatorImage, let nameText = testatorNameTextField.text, nameText.characters.count > 0 else {
            return
        }
        
        TestatorModelController.shared.createTestator(name: nameText, image: testatorImage) { 
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension NewTestatorPopoverViewController: PhotoSelectViewControllerDelegate {
    func photoSelectViewControllerSelectedImage(image: UIImage) {
        self.testatorImage = image
    }
}
