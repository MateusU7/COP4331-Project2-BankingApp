//
//  HomeViewController.swift
//  Swift Safe
//
//  Created by Mateus Urbanski on 11/24/20.
//  Copyright © 2020 Mateus Urbanski. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    var email = ""
    
    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var checkingButton: UIButton!
    
    @IBOutlet weak var savingsButton: UIButton!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let db = Firestore.firestore()
        let docRef = db.collection("users").document(email)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {

                let firstName = document.get("firstname") as! String
                let lastName = document.get("lastname") as! String
                
                self.welcomeLabel.text = "Welcome " + firstName + " " + lastName
                
            } else {
                print("Document does not exist")
            }
        }
        
        // Do any additional setup after loading the view.
        setUpElements()
        
    }
    
    func setUpElements() {
        
        Utilities.styleHollowButton(logoutButton)
        Utilities.styleFilledButton(checkingButton)
        Utilities.styleFilledButton(savingsButton)
        Utilities.styleFilledButton(sendButton)
        
    }

    @IBAction func checkingTapped(_ sender: Any) {
        performSegue(withIdentifier: "toCheckingVC", sender: self)
    }
    
    @IBAction func savingsTapped(_ sender: Any) {
        performSegue(withIdentifier: "toSavingsVC", sender: self)
    }
    
    @IBAction func sendTapped(_ sender: Any) {
        performSegue(withIdentifier: "toSendVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCheckingVC" {
            let vc = segue.destination as! CheckingViewController
            vc.email = self.email
        } else if segue.identifier == "toSavingsVC" {
            let vc = segue.destination as! SavingsViewController
            vc.email = self.email
        } else if segue.identifier == "toSendVC" {
            let vc = segue.destination as! SendViewController
            vc.email = self.email
        }
    }
    
    @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {}
    
    @IBAction func logoutTapped(_ sender: Any) {
        
        let viewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.ViewController) as? ViewController
        
        view.window?.rootViewController = viewController
        view.window?.makeKeyAndVisible()
        
    }
    
}
