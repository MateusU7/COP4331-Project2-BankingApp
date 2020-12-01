//
//  TableViewCell.swift
//  Swift Safe
//
//  Created by Mateus Urbanski on 11/27/20.
//  Copyright © 2020 Mateus Urbanski. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var idColumn: UILabel!
    
    @IBOutlet weak var dateColumn: UILabel!
    
    @IBOutlet weak var merchantColumn: UILabel!
    
    @IBOutlet weak var amountColumn: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
