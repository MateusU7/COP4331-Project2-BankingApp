//
//  SavingsViewController.swift
//  Swift Safe
//
//  Created by Mateus Urbanski on 11/26/20.
//  Copyright © 2020 Mateus Urbanski. All rights reserved.
//

import UIKit
import Firebase

class SavingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var email = ""
    let sections = ["ID         Timestamp           Merchant     Amount", "Timestamp", "Merchant", "Amount"]
    var ids = [] as [String]
    var timestamps = [] as [String]
    var merchants = [] as [String]
    var amounts = [] as [String]

    @IBOutlet weak var balanceLabel: UILabel!
    
    @IBOutlet weak var transactionTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transactionTable.dataSource = self
        
        let nf = NumberFormatter()
        nf.usesGroupingSeparator = true
        nf.numberStyle = .currency
        nf.locale = Locale(identifier: "en_US")
        
        let df = DateFormatter()
        df.dateFormat = "MM/dd"
        
        // Accessing acconut balance amount
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(email)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {

                let results = document.data()
                if let idData = results!["Savings"] as? [String: Any] {
                    let balance = idData["balance"] as! NSNumber
                    
                    self.balanceLabel.text = (nf.string(for: balance)!)
                }
                
            } else {
                print("Document does not exist")
            }
        }
        
        // Accessing account transactions
        db.collection("users").document(email).collection("Savings").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    self.ids.append(String(document.documentID.prefix(4)).uppercased())
                    
                    let timestamp: Timestamp = document.get("date") as! Timestamp
                    let date: Date = timestamp.dateValue()
                    self.timestamps.append(df.string(from: date))
                    
                    self.merchants.append(document.get("merchant") as! String)
                    
                    let amount = document.get("amount") as! NSNumber
                    self.amounts.append(nf.string(for: amount)!)
                    
                }
            }
            
            DispatchQueue.main.async {
                self.transactionTable.reloadData()
            }

        }
        
        // Do any additional setup after loading the view.
        setUpElements()
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ids.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create an object of the dynamic cell "PlainCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlainCell", for: indexPath) as! TableViewCell
        
        cell.idColumn.text = ids[indexPath.row]
        cell.dateColumn.text = timestamps[indexPath.row]
        cell.merchantColumn.text = merchants[indexPath.row]
        cell.amountColumn.text = amounts[indexPath.row]
        
        // Return the configured cell
        return cell

    }

    func setUpElements () {
        // Hide the error label
//        errorLabel.alpha = 0
//
//        // Style the elements
//        Utilities.styleTextField(emailTextField)
//        Utilities.styleTextField(passwordTextField)
//        Utilities.styleFilledButton(loginButton)
    }

}
