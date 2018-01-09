//
//  CustomTextField.swift
//  HebrewDictionary
//
//  Created by Laura Evans on 1/9/18.
//  Copyright © 2018 Laura Evans. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {

    var language: String?
    
    override var textInputMode: UITextInputMode? {
        if let language = language {
            for tim in UITextInputMode.activeInputModes {
                if tim.primaryLanguage!.contains(language) {
                    return tim
                }
            }
            return super.textInputMode
        } else {
            return super.textInputMode
        }
    }
}
