//
//  Utilities.swift
//  Street Vendor Helper
//
//  Created by owner on 9/24/19.
//  Copyright © 2019 Theophilus Drackett. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    
    static func styleTextField(_ textfield:UITextField) {
        
        // Create the bottom line
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width, height: 2)
        
        bottomLine.backgroundColor = UIColor.init(red: 212.0/255.0, green: 175.0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
        // Remove border on text field
        textfield.borderStyle = .none
        textfield.textColor = UIColor.black
        textfield.backgroundColor = UIColor.white
        
        
        // Add the line to the text field
//        textfield.layer.addSublayer(bottomLine)
        
    }
    
    static func styleLabel(_ label:UILabel) {
            
            // Create the bottom line
            let bottomLine = CALayer()
            
            bottomLine.frame = CGRect(x: 0, y: label.frame.height - 2, width: label.frame.width, height: 2)
            
        label.textColor = UIColor.black
            bottomLine.backgroundColor = UIColor.init(red: 212.0/255.0, green: 175.0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
            
        }
    
    static func styleTextview(_ textview:UITextView) {
            

        textview.backgroundColor = UIColor.white
        textview.textColor = UIColor.black
    }

    static func styleFilledButton(_ button:UIButton) {
        
        // Filled rounded corner style
//        button.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1)
        button.backgroundColor = UIColor.init(red: 212.0/255.0, green: 175.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.white
    }
    
    static func styleHollowButton(_ button:UIButton) {
        
        // Hollow rounded corner style
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.black
    }
    
    static func isPasswordValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
}

