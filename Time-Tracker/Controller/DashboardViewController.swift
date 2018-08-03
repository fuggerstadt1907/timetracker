//
//  DashboardViewController.swift
//  Time-Tracker
//
//  Created by Alessandro Orlandi on 25.07.18.
//  Copyright © 2018 Alessandro Orlandi. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var selectDateBtn: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        selectDateBtn.setTitle(formatDatePickerValue(), for: .normal)
        datePicker.maximumDate = Date()
        self.tabBarItem = UITabBarItem(title: "Dashboard", image: #imageLiteral(resourceName: "DashboardIcon"), tag: 1)
    }

    // FUNCTION THAT IS CALLED WHEN DATE BUTTON HAS BEEN PRESSED
    @IBAction func selectDateHandler(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.datePicker.isHidden = !self.datePicker.isHidden
            self.view.layoutIfNeeded()
        })
    }
    
    
    // FUNCTION THAT IS CALLED AFTER DATE PICKER CHANGED
    @IBAction func datePickerHandler(_ sender: Any) {
        self.selectDateBtn.setTitle(formatDatePickerValue(), for: .normal)
    }

    
    // FUNCTION THAT IS CALLED TO FORMAT DATEPICKER VALUE
    private func formatDatePickerValue() -> String {
        let dateFormatter = DateFormatter()
        let date = self.datePicker.date
        dateFormatter.dateFormat = "EEEE, dd.MM.yyyy"
        return  dateFormatter.string(from: date)
    }
    
}
