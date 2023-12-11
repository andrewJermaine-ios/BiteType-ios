//
//  FMTextField.swift
//  MacroMeals
//
//  Created by Andrew on 12/3/23.
//

import UIKit

open class FMTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    func setup() {
        self.font = UIFont(name: "AvenirNext-Medium", size: 20.0)
        self.textColor = UIColor.black

    }
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        required public init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setup()
        }

}
