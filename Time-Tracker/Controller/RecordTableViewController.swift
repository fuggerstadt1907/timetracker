//
//  RecordTableViewController.swift
//  Time-Tracker
//
//  Created by Alessandro Orlandi on 24.07.18.
//  Copyright © 2018 Alessandro Orlandi. All rights reserved.
//

import UIKit

class RecordTableViewController: UITableViewController {
    
    var tempCategoryItems = [CategoryItem]()
    var countdownTimer = [Timer]()
    var totalTime = 0
    
    @IBAction func resetAllTimers(_ sender: UIBarButtonItem) {
        let indexPathsArray = tableView.indexPathsForVisibleRows
        for indexPath in indexPathsArray! {
            let cell = tableView.cellForRow(at: indexPath) as! RecordTableViewCell
            if cell.isRecording {
                cell.timer.invalidate()
                cell.categoryTimeLabel.text = "00:00:00"
                cell.time = 0
                cell.categoryActionButton.setImage(#imageLiteral(resourceName: "playIcon"), for: .normal)
                cell.isRecording = false
                print("All Timers stopped and set to 0")
            }
            else {
                cell.categoryTimeLabel.text = "00:00:00"
                cell.time = 0
                cell.categoryActionButton.setImage(#imageLiteral(resourceName: "playIcon"), for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = getCurrentDate()
        
        tempCategoryItems = [
            CategoryItem(categoryName: "Testprojekt")]
        
        self.tabBarItem = UITabBarItem(title: "Erfassen", image: #imageLiteral(resourceName: "playIcon"), tag: 0)
    }
    
    
    @IBAction func addNewItem(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Neue Kategorie", message: "Lege eine neue Kategorie an.", preferredStyle: .alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Name der Kategorie"
        }
        
        let saveAction = UIAlertAction(title: "Hinzufügen", style: .default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0].text
            if alertController.textFields![0].text != "" {
                self.tempCategoryItems.append(CategoryItem(categoryName: firstTextField))
                self.tableView.reloadData()
            } else {
                self.displayAlertWithOkBtn(title: "Fehler beim Speichern", message: "Bitte gib einen Namen für die Kategorie an.")
                return
            }
        })
        
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .default, handler: { (action : UIAlertAction!) -> Void in })
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    private func displayAlertWithOkBtn(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Okay", style: .default, handler: { _ in })
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    private func displayAlertWithTwoBtns(title: String, message: String, actionBtnText: String, cancelBtnText: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let firstAction = UIAlertAction(title: actionBtnText, style: .default) { alert -> Void in
            // TODO
        }
        let cancelAction = UIAlertAction(title: cancelBtnText, style: .default, handler: { (action : UIAlertAction!) -> Void in })
        alert.addAction(cancelAction)
        alert.addAction(firstAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    private func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        let date = Date()
        dateFormatter.dateFormat = "EEEE, dd.MM.yyyy"
        return  dateFormatter.string(from: date)
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row with Index \(indexPath.row) selected")
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempCategoryItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tempItem = tempCategoryItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecordTableViewCell
        cell.categoryLabel?.text = tempItem.categoryName
        cell.categoryTimeLabel?.text = "00:00:00"
        return cell
    }
 
}

