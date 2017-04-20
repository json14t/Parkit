//
//  CustomButton.swift
//  Parkit
//
//  Created by Jason Campoverde on 3/31/17.
//  Copyright © 2017 Jason Campoverde. All rights reserved.
//

import UIKit

class CustomButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 5
        self.backgroundColor = UIColor.clear
        //self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        self.setTitleColor(UIColor.black, for: .normal)
        //self.sizeToFit()
    }

}
