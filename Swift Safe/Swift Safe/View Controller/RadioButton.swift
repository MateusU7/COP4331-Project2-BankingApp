//
//  RadioButton.swift
//  Swift Safe
//
//  Created by Mateus Urbanski on 11/28/20.
//  Copyright © 2020 Mateus Urbanski. All rights reserved.
//

import Foundation
import UIKit

class RadioButton: UIButton {
    
    var alternateButton:Array<RadioButton>?
    
    override func awakeFromNib() {
        
        self.setTitleColor(UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1), for: .normal)
        self.setTitleColor(UIColor.init(red: 48/255, green: 173/255, blue: 199/255, alpha: 1), for: .selected)
        
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 2.0
        self.layer.masksToBounds = true
        
    }
    
    func setButtonTitle(title:String) {
        setTitle(title, for: .normal)
        setTitle(title, for: .selected)
        setTitle(title, for: .highlighted)
    }
    
    func unselectAlternateButtons() {
        if alternateButton != nil {
            self.isSelected = true
            
            for aButton:RadioButton in alternateButton! {
                aButton.isSelected = false
            }
        } else {
            toggleButton()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        unselectAlternateButtons()
        super.touchesBegan(touches, with: event)
    }
    
    func toggleButton() {
        self.isSelected = !isSelected
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.layer.borderColor = UIColor.init(red: 48/255, green: 173/255, blue: 199/255, alpha: 0.8).cgColor
            } else {
                self.layer.borderColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8).cgColor
            }
        }
    }
}
