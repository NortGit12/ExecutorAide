//
//  NewSubTaskViewController.swift
//  ExecutorAide
//
//  Created by Tim on 9/27/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit

class NewSubTaskViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var nameTextField: CustomTextField!
    @IBOutlet weak var descriptorTextField: CustomTextField!
    @IBOutlet weak var taskField: CustomTextField!
    
    var pickerView: UIPickerView!
    
    var parentTask: Task?
    
    weak var delegate: NewElementDelegate?
    
    var pickerViewDataSource: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - TextField Delegate Methods
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        
        let pickerHeight: CGFloat = 200
        pickerView = UIPickerView(frame: CGRect(x: 0, y: self.view.frame.height - pickerHeight, width: self.view.frame.width, height: pickerHeight))
        pickerView.backgroundColor = .clear
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // Picker toolbar
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewSubTaskViewController.pickerIsDone))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewSubTaskViewController.pickerIsCancelled))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
//        view.addSubview(pickerView)
        
        taskField.inputView = pickerView
        taskField.inputAccessoryView = toolBar
            
        return true
    }
    
    func pickerIsDone() {
        pickerView.endEditing(true)
    }
    
    func pickerIsCancelled() {
        pickerView.endEditing(true)
        
    }
    
    // MARK: - PickerViewDelegate and DataSource Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerViewDataSource[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        taskField.text = pickerViewDataSource[row].name
        parentTask = pickerViewDataSource[row]
    }

    // MARK: - IBActions
    
    @IBAction func doneAction(_ sender: AnyObject) {
        guard let nameText = nameTextField.text, let taskName = taskField.text else { return }
        if !nameText.isEmpty && !taskName.isEmpty {
            guard let parentTask = parentTask else {
                print("No parent task specified")
                return
            }
            
            guard let descriptor = descriptorTextField.text else { return }
            guard let subTask = SubTask(descriptor: descriptor, name: nameText, sortValue: 0, task: parentTask) else { return }
            
            SubTaskModelController.shared.createSubTask(subTask: subTask, completion: { 
                self.dismiss(animated: true, completion: { 
                    self.delegate?.stageWillUpdateWithNewData()
                })
            })
            
        } else {
            return
        }
    }
    
    @IBAction func cancelAction(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

}
