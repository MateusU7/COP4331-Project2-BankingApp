//
//  SendViewController.swift
//  Swift Safe
//
//  Created by Mateus Urbanski on 11/28/20.
//  Copyright © 2020 Mateus Urbanski. All rights reserved.
//

import UIKit
import Firebase

class SendViewController: UIViewController, UITextFieldDelegate {

    var email = ""
    
    var senderSelected:String = ""
    var recipientSelected:String = ""
    var finalRecipient: String = ""
    var finalAmount: Double = 0
    
    @IBOutlet weak var senderFullName: UILabel!
    @IBOutlet weak var recipientFullName: UILabel!

    @IBOutlet weak var senderCheckingButton: RadioButton!
    
    @IBOutlet weak var senderSavingsButton: RadioButton!
    
    @IBOutlet weak var recipientTextField: UITextField!
    
    @IBOutlet weak var recipientError: UILabel!
    
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var amountError: UILabel!
    
    @IBOutlet weak var recipientAccounts: UIStackView!
    
    @IBOutlet weak var recipientCheckingButton: RadioButton!
    
    @IBOutlet weak var recipientSavingsButton: RadioButton!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var sendError: UILabel!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        recipientTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
        return true
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        recipientTextField.delegate = self
        amountTextField.delegate = self
        amountTextField.keyboardType = .decimalPad
 
        self.view.layoutIfNeeded()

        senderCheckingButton.isSelected = false
        senderSavingsButton.isSelected = false

        recipientCheckingButton.isSelected = false
        recipientSavingsButton.isSelected = false
        
        // Do any additional setup after loading the view.
        setUpElements()

        populateSenderAccounts()

    }
    
    // Accessing account balances
    func populateSenderAccounts() {
        
        let nf = NumberFormatter()
        nf.usesGroupingSeparator = true
        nf.numberStyle = .currency
        nf.locale = Locale(identifier: "en_US")
        
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(email)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {

                let results = document.data()
                if let idData = results!["Checking"] as? [String: Any] {
                    let balance = idData["balance"] as! NSNumber

                    self.senderCheckingButton.setButtonTitle(title: "Checking - " + (nf.string(for: balance)!))
                }
                if let idData = results!["Savings"] as? [String: Any] {
                    let balance = idData["balance"] as! NSNumber

                    self.senderSavingsButton.setButtonTitle(title: "Savings - " + (nf.string(for: balance)!))
                }

            } else {
                print("Document does not exist")
            }
        }
        
    }
    
    func searchUser(completion: @escaping (Bool) -> Void) {
        
        var final: Bool = false
        
        let recipient = recipientTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if recipient != "" {

            search(user:recipient!) { (result) in
                if result {
                    self.recipientError.alpha = 0
                    final = true
                } else {
                    self.showError(errorLabel: self.recipientError, message: "User not found.")
                    final = false
                }
                completion(final)
            }
        }
    }
    
    func search(user:String, completion: @escaping (Bool) -> Void) -> Void {
        
        let db = Firestore.firestore()
        
        let docRef = db.collection("users").document(user)
        docRef.getDocument { (document, error) in
            var result:Bool
            if let document = document, document.exists {
                result = true
            } else {
                result = false
            }
            completion(result)
        }
    }
    
    func validateFields() -> Bool {
        
        // Buttons are pressed
        if senderCheckingButton.isSelected || senderSavingsButton.isSelected {
            if senderCheckingButton.isSelected {
                senderSelected = "Checking"
            } else {
                senderSelected = "Savings"
            }
        } else {
            showError(errorLabel: sendError, message: "Please fill in all fields.")
            return false
        }
        
        if recipientCheckingButton.isSelected || recipientSavingsButton.isSelected {
            if recipientCheckingButton.isSelected {
                recipientSelected = "Checking"
            } else {
                recipientSelected = "Savings"
            }
        } else {
            showError(errorLabel: sendError, message: "Please fill in all fields.")
            return false
        }
        
        // Check that all fields are filled in
        if recipientTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || amountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            showError(errorLabel: sendError, message: "Please fill in all fields.")
            return false
        }
        else {
            sendError.alpha = 0
            
            return true
        }
    }
    
    func validateAmount(completion: (Bool) -> Void) {
        
        let newText = amountTextField.text!
        let isNumeric = Double(newText) != nil
        let numberOfDots = newText.components(separatedBy: ".").count - 1

        let numberOfDecimalDigits: Int
        if let dotIndex = newText.firstIndex(of: ".") {
            numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
        } else {
            numberOfDecimalDigits = 0
        }

        let ch: Character = "-"
        
        let result = !(newText.contains(ch)) && !(newText.isEmpty) && isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 2
        
        if result {
            amountError.alpha = 0
        } else {
            showError(errorLabel: amountError, message: "Amount is invalid.")
        }
        
        completion(result)
        
    }
    
    func validateFunds(completion: @escaping (Bool) -> Void) {
        
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(email)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {

                let results = document.data()
                if let idData = results![self.senderSelected] as? [String: Any] {
                    var result:Bool = false
                    
                    let balance = idData["balance"] as! NSNumber
                    let balanceDouble = balance.doubleValue
                    
                    if ((balanceDouble - self.finalAmount) < 0) {
                        self.showError(errorLabel: self.amountError, message: "Insufficient funds.")
                        result = false
                    } else {
                        self.amountError.alpha = 0
                        result = true
                    }
                    
                    completion(result)
                }

            } else {
                print("Document does not exist")
            }
        }
    }
    
    func createNewTransactions(amount: Double) {
        let db = Firestore.firestore()
        
        self.getSenderFullName { senderFullName in
            let docRef = db.collection("users").document(self.finalRecipient).collection(self.recipientSelected)
            docRef.document().setData([
                "amount": amount,
                "date": Timestamp.init(),
                "merchant": senderFullName,
                ])
        }
        
        self.getRecipientFullName { recipientFullName in
            let docRef = db.collection("users").document(self.email).collection(self.senderSelected)
            docRef.document().setData([
                "amount": -amount,
                "date": Timestamp.init(),
                "merchant": recipientFullName,
                ])
        }
        
        let accountName = recipientSelected + ".balance"
        let docRef = db.collection("users").document(self.finalRecipient)
        docRef.updateData([
            accountName: FieldValue.increment(self.finalAmount)
        ])
        
        let accountName2 = senderSelected + ".balance"
        let docRef2 = db.collection("users").document(self.email)
        docRef2.updateData([
            accountName2: FieldValue.increment(-self.finalAmount)
        ])
    }
    
    func getSenderFullName(completion: @escaping (String) -> Void) {
        let db = Firestore.firestore()
        
        let docRef = db.collection("users").document(email)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {

                let firstName = document.get("firstname") as! String
                let lastName = document.get("lastname") as! String
                
                let senderFullName = firstName + " " + lastName
                
                completion(senderFullName)
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func getRecipientFullName(completion: @escaping (String) -> Void) {
        let db = Firestore.firestore()
        
        let docRef = db.collection("users").document(self.finalRecipient)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {

                let firstName = document.get("firstname") as! String
                let lastName = document.get("lastname") as! String
                
                let recipientFullName = firstName + " " + lastName
                
                completion(recipientFullName)
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func showError(errorLabel:UILabel, message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func showFeedback() {
        
        let nf = NumberFormatter()
        nf.usesGroupingSeparator = true
        nf.numberStyle = .currency
        nf.locale = Locale(identifier: "en_US")
        
        // Create the alert
        self.getRecipientFullName { recipientFullName in
            let formattedString = (nf.string(for: self.finalAmount)!)
            let message1 = "You sent " + formattedString + " to "
            let message2 = recipientFullName + "'s " + self.recipientSelected + " account."
            let message = message1 + message2
            
            let alert = UIAlertController(title: "Transaction Successful", message: message, preferredStyle: UIAlertController.Style.alert)
            
            // Add "OK" action (button) to bring back to home page
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                
                // Unwind segue
                self.performSegue(withIdentifier: "unwindToHome", sender: action)
                
            }
            ))

            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func sendButtonTapped(_ sender: Any) {
        // Check for empty fields
        if validateFields() {
            
            // Search for valid user
            searchUser { result in
                if result {
                    
                    // Ensure valid amount
                    self.validateAmount { result2 in
                        if result2 {
                        
                            self.finalAmount = Double(self.amountTextField.text!)!
                            
                            self.validateFunds { [self] result3 in
                                if result3 {
                                    
                                    self.finalRecipient = (self.recipientTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
                                    
                                    // Update sender and recipient's balance and transactions
                                    self.createNewTransactions(amount: self.finalAmount)
                                    
                                    // User Feedback
                                    self.showFeedback()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setUpElements() {
        // Hide errors
        recipientError.alpha = 0
        amountError.alpha = 0
        sendError.alpha = 0
        
        // Set up radio buttons
        senderCheckingButton?.alternateButton = [senderSavingsButton!]
        senderSavingsButton?.alternateButton = [senderCheckingButton!]
        
        recipientCheckingButton?.alternateButton = [recipientSavingsButton!]
        recipientSavingsButton?.alternateButton = [recipientCheckingButton!]
        
        // Style the elements
        Utilities.styleTextField(recipientTextField)
        Utilities.styleTextField(amountTextField)
        Utilities.styleFilledButton(sendButton)
    }
    
    

}
