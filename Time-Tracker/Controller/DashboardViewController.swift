//
//  DashboardViewController.swift
//  Time-Tracker
//
//  Created by Alessandro Orlandi on 25.07.18.
//  Copyright © 2018 Alessandro Orlandi. All rights reserved.
//

import UIKit
import Firebase
import Charts

class DashboardViewController: UIViewController {
    
    
    
    
    // CUSTOM VARIABLES
    //var firstChartData = PieChartDataEntry(value: 0)
    //var secondChartData = PieChartDataEntry(value: 0)
    var itemNames = [String]()
    var itemTimeValue = [Double]()
    var dataEntries: [BarChartDataEntry] = []
    var numberOfDataEntries = [PieChartDataEntry]()

    
    
    
    // FIRESTORE
    lazy var db = Firestore.firestore()
    
    
    
    // DASBOARD VIEW OUTLETS
    @IBOutlet weak var selectDateBtn: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var pieChart: PieChartView!
    
    
    
    
    // VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
                
        selectDateBtn.setTitle(formatDatePickerValue(), for: .normal)
        datePicker.maximumDate = Date()
        
        // Chart Data
        self.pieChart.chartDescription?.text = ""
        pieChart.noDataText = "Es wurden keine Daten gefunden"
        //firstChartData.data = 5 as AnyObject
        //firstChartData.value = 100
        //firstChartData.label = "first Data"
        //secondChartData.data = 10 as AnyObject
        //secondChartData.label = "second Data"
        //numberOfDataEntries = [dictOfItems]
        getDashboardDataFromDB()
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
        getDashboardDataFromDB()
    }
    
    
    
    
    // FUNCTION THAT IS CALLED TO GET DASHBOARD DATA FROM DB
    func getDashboardDataFromDB() {
        let selectedDate = formatDatePickerValueForDbDoc()
        print("Selcted date = \(selectedDate)")
        
        let docRef = db.collection(Utilities.getCurrentYear()).document(Utilities.getCurrenMonth()).collection(selectedDate)
        docRef.getDocuments { (snapshot, err) in
            if let err = err {
                Utilities.displayAlertWithOkBtn(title: "Fehler", message: "Ein Fehler ist aufgetreten: \n\(err.localizedDescription)")
            }
            else {
                for document in snapshot!.documents {
                    let timeValue = document.data()["timer"] as! Double
                    let name = document.data()["name"] as! String
                    print("Timer-Values from DB: \(timeValue)")
                    self.itemNames.append(name)
                    self.itemTimeValue.append(timeValue)
                    print("Names: \(self.itemNames)")
                    print("Timers: \(self.itemTimeValue)")
                    
                    for i in 0..<self.itemNames.count {
                        let dataPoint = BarChartDataEntry(x: Double(i), y: Double(self.itemTimeValue[i]))
                        self.dataEntries.append(dataPoint)
                        
                        let chartDataSet = PieChartDataSet(values: self.dataEntries, label: "test")
                        let chartData = PieChartData(dataSet: chartDataSet)
                        
                        let colors = [CategoryColors.Green, CategoryColors.Purple]
                        chartDataSet.colors = colors
                        
                        self.pieChart.data = chartData
                    }
                    
                    
                }
            }
        }
        
    }

    
    
    
    // FUNCTION THAT IS CALLED TO FORMAT DATEPICKER VALUE
    private func formatDatePickerValue() -> String {
        let dateFormatter = DateFormatter()
        let date = self.datePicker.date
        dateFormatter.dateFormat = "EEEE, dd.MM.yyyy"
        return  dateFormatter.string(from: date)
    }
    
    
    
    
    // FUNCTION THAT IS CALLED TO FORMAT DATEPICKER VALUE
    private func formatDatePickerValueForDbDoc() -> String {
        let dateFormatter = DateFormatter()
        let date = self.datePicker.date
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return  dateFormatter.string(from: date)
    }
    
}
