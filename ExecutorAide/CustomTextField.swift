//
//  CustomTextField.swift
//  ExecutorAide
//
//  Created by Tim on 9/30/16.
//  Copyright © 2016 NortCham. All rights reserved.
//

import UIKit

@IBDesignable
class CustomTextField: UITextField {

    var underlineColor: CGColor = UIColor.lightGray.cgColor
    var underlineWidth: CGFloat = 2.0
    
    // MARK: - Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupTextField()
    }

    func setupTextField() {
        // Text
        // TODO: Use Appearance Controller
        self.font = UIFont(name: "Avenir Next", size: 21)
        
        self.borderStyle = .none
        let border = CALayer()
        border.borderColor = underlineColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - underlineWidth, width: self.frame.size.width, height: self.frame.size.height)
        
        border.borderWidth = underlineWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    
}
