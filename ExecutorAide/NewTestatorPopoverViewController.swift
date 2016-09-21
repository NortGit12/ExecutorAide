//
//  NewTestatorPopoverViewController.swift
//  ExecutorAide
//
//  Created by Tim on 9/15/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit

class NewTestatorPopoverViewController: UIViewController {

    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var testatorNameTextField: UITextField!
    
    var testatorImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorView.isHidden = true
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
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? ImageSelectionViewController else { return }
        if segue.identifier == "imagePickerEmbed" {
            destinationVC.delegate = self
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        activityIndicatorView.isHidden = false
        if let nameText = testatorNameTextField.text {
            guard let testatorImage = testatorImage else {
                TestatorModelController.shared.createTestator(image: UIImage(named: "user"), name: nameText, completion: { (testator) in
                    guard let testator = testator else { return }
                    DataTemplateController.initializeTemplate(forTestator: testator)
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                })
                return
            }
            
            // Image was picked
            TestatorModelController.shared.createTestator(image: testatorImage, name: nameText, completion: { (testator) in
                guard let testator = testator else { return }
                DataTemplateController.initializeTemplate(forTestator: testator)
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            })
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
