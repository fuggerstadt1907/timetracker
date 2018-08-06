//
//  DashboardViewController.swift
//  Time-Tracker
//
//  Created by Alessandro Orlandi on 25.07.18.
//  Copyright © 2018 Alessandro Orlandi. All rights reserved.
//

import UIKit
//import FirebaseFirestore
import Charts

class DashboardViewController: UIViewController {
    
    
    // CUSTOM VARIABLES
    var firstChartData = PieChartDataEntry(value: 55)
    var secondChartData = PieChartDataEntry(value: 11)
    var numberOfDataEntries = [PieChartDataEntry]()
    var firstNumber = 44 as AnyObject
    var secondNumber = 10 as AnyObject
    
    
    // Dasboard View Outlets
    @IBOutlet weak var selectDateBtn: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var pieChart: PieChartView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectDateBtn.setTitle(formatDatePickerValue(), for: .normal)
        datePicker.maximumDate = Date()
        
        // Chart Data
        self.pieChart.chartDescription?.text = ""
        firstChartData.data = self.firstNumber
        firstChartData.label = "first Data"
        secondChartData.data = self.secondNumber
        secondChartData.label = "second Data"
        numberOfDataEntries = [firstChartData, secondChartData]
        updateChartData()
        
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
    
    
    // FUNCTION THAT IS CALLED TO UPDATE THE PIE CHART
    func updateChartData(){
        let chartDataSet = PieChartDataSet(values: numberOfDataEntries, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        
        let colors = [CategoryColors.Green, CategoryColors.Purple]
        chartDataSet.colors = colors
        
        pieChart.data = chartData
    }

    
    // FUNCTION THAT IS CALLED TO FORMAT DATEPICKER VALUE
    private func formatDatePickerValue() -> String {
        let dateFormatter = DateFormatter()
        let date = self.datePicker.date
        dateFormatter.dateFormat = "EEEE, dd.MM.yyyy"
        return  dateFormatter.string(from: date)
    }
    
}
