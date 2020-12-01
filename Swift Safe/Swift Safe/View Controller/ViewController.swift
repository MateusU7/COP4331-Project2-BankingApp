//
//  ViewController.swift
//  Swift Safe
//
//  Created by Mateus Urbanski on 11/24/20.
//  Copyright © 2020 Mateus Urbanski. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpElements()
        
    }
    
    func setUpElements() {
        
        Utilities.styleHollowButton(loginButton)
        
    }
}

