//
//  RecordTableViewCell.swift
//  Time-Tracker
//
//  Created by Alessandro Orlandi on 26.07.18.
//  Copyright © 2018 Alessandro Orlandi. All rights reserved.
//

import UIKit

class RecordTableViewCell: UITableViewCell {

    // Tableview Cell Outlets
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryTimeLabel: UILabel!
    @IBOutlet weak var categoryActionButton: UIButton!
    
    @IBAction func recordTimeHandler(_ sender: UIButton) {
        
    }

}
