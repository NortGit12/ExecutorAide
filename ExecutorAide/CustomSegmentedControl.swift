//
//  CustomSegmentedControl.swift
//  ExecutorAide
//
//  Created by Tim on 9/30/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit

@IBDesignable
class CustomSegmentedControl: UIControl {
    
    private var labels = [UILabel]()
    
    var selectedSegmentIndicator = UIView()
    
    var items:[String] = ["Stage 1", "Stage 2", "Stage 3"] {
        didSet {
            setupLabels()
        }
    }
    
    var selectedIndex: Int = 0 {
        didSet {
            displayNewSelectedIndex()
        }
    }
    
    // Appearance customization properties
    var animationDuration = 0.25
    var labelColor: UIColor = .black
    var indicatorHeight: CGFloat = 3.0
    var indicatorColor: UIColor = .black
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    
    func setupView() {
        backgroundColor = UIColor.clear
        setupLabels()
        insertSubview(selectedSegmentIndicator, at: 0)
    }
    
    func setupLabels() {
        for label in labels {
            label.removeFromSuperview()
        }
        labels.removeAll(keepingCapacity: true)
        
        for index in 1...items.count {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            label.text = items[index - 1]
            label.textAlignment = .center
            label.textColor = .black
            label.font = UIFont(name: "Avenir Next", size: 18)
            label.lineBreakMode = NSLineBreakMode.byWordWrapping
            label.numberOfLines = 0
            self.addSubview(label)
            labels.append(label)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var selectedFrame = self.bounds
        let newWith = selectedFrame.width / CGFloat(items.count)
        selectedFrame.size.width = newWith
        
        let xPosition = labels[selectedIndex].frame.origin.x
        selectedSegmentIndicator.frame = CGRect(x: xPosition, y: self.frame.height - indicatorHeight, width: selectedFrame.width, height: indicatorHeight)
        selectedSegmentIndicator.backgroundColor = indicatorColor
        selectedSegmentIndicator.layer.cornerRadius = selectedSegmentIndicator.frame.height/2
        
        let labelHeight = self.bounds.height
        let labelWidth = self.bounds.width / CGFloat(labels.count)
        
        for index in 0...labels.count - 1 {
            let label = labels[index]
            
            let xPosition = CGFloat(index) * labelWidth
            
            label.frame = CGRect(x: xPosition, y: 0, width: labelWidth, height: labelHeight)
        }
    }
    
    // Calculates which segment received a tap
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        var calculatedIndex: Int?
        for (index, item) in labels.enumerated() {
            if item.frame.contains(location) {
                calculatedIndex = index
            }
        }
        
        if calculatedIndex != nil {
            selectedIndex = calculatedIndex!
            sendActions(for: .valueChanged)
        }
        return false
    }
    
    func displayNewSelectedIndex() {
        let label = labels[selectedIndex]
        let newSelectedSegmentIndicatorFrame = CGRect(x: label.frame.origin.x, y: self.frame.height - indicatorHeight, width: label.frame.width, height: indicatorHeight)
        animateSelection(newFrame: newSelectedSegmentIndicatorFrame)
    }
    
    func animateSelection(newFrame: CGRect) {
        UIView.animate(withDuration: self.animationDuration) {
            self.selectedSegmentIndicator.frame = newFrame
        }
    }
}
