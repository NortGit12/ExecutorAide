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
    @IBOutlet weak var selectImageButton: UIButton!
    
    var testatorImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func setupPopoverDisplay(containerWidth: CGFloat, containerHeight: CGFloat) {
        self.view.backgroundColor = UIColor.clear
        self.preferredContentSize = CGSize(width: containerWidth/2, height: containerHeight/2)
    }
    
    @IBAction func selectImageButtonTapped(_ sender: AnyObject) {
    
    }
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        
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
