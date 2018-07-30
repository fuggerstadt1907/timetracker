//
//  RecordTableViewController.swift
//  Time-Tracker
//
//  Created by Alessandro Orlandi on 24.07.18.
//  Copyright © 2018 Alessandro Orlandi. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Crashlytics


class RecordTableViewController: UITableViewController {
    
    
    // CUSTOM VARIABLES
    var tempCategoryItems = [CategoryItem]()
    var countdownTimer = [Timer]()
    var totalTime = 0
    
    
    
    // TABLEVIEW CONTROLLER OUTLETS
    // FUNCTION THAT IS CALLED TO RESET ALL TIMERS
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
    
    
    @IBAction func moveToFirebaseDB(_ sender: UIBarButtonItem) {
        let indexPathsArray = tableView.indexPathsForVisibleRows
        for indexPath in indexPathsArray! {
            let cell = tableView.cellForRow(at: indexPath) as! RecordTableViewCell
            cell.saveAfterCheckToDB(name: cell.categoryLabel.text!, recordedTime: cell.categoryTimeLabel.text!)
        }
    }
    
    
    // VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        tempCategoryItems = [CategoryItem(categoryName: "Testprojekt", recordedTime: nil)]
        
        self.title = getCurrentDate()
        self.tableView.delaysContentTouches = false
        self.tabBarItem = UITabBarItem(title: "Erfassen", image: #imageLiteral(resourceName: "RecentIcon"), tag: 0)
    }
    
    
    
    // FUNCTION THAT IS CALLED TO ADD A NEW ITEM
    @IBAction func addNewItem(_ sender: UIBarButtonItem) {
        showInputDialog()
    }
    
    
    // FUNCTION THAT IS CALLED TO SHOW DIALOG FOR NEW ITEM
    private func showInputDialog(){
        let alertController = UIAlertController(title: "Neue Kategorie", message: "Lege eine neue Kategorie an.", preferredStyle: .alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Name der Kategorie"
        }
        
        let saveAction = UIAlertAction(title: "Hinzufügen", style: .default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0].text
            if alertController.textFields![0].text != "" {
                self.tempCategoryItems.append(CategoryItem(categoryName: firstTextField!, recordedTime: nil))
                self.tableView.reloadData()
            } else {
                self.displayAlertWithOkBtn(title: "Fehler beim Speichern", message: "Bitte gib einen Namen an.")
                return
            }
        })
        
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .default, handler: { (action : UIAlertAction!) -> Void in })
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // FUNCTION THAT IS CALLED TO BUID AN ALERT WITH OK BUTTON
    private func displayAlertWithOkBtn(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Okay", style: .default, handler: { _ in })
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // FUNCTION THAT IS CALLED TO BUILD AN ALERT WITH TWO BUTTONS
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
    
    
    // FUNCTION THAT IS CALLED TO GET THE CURRENT DAY AND DATE
    private func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        let date = Date()
        dateFormatter.dateFormat = "EEEE, dd.MM.yyyy"
        return  dateFormatter.string(from: date)
    }
        
    
    // FUNCTION THAT IS CALLED TO SET THE NUMBER OF SECTIONS IN THE TABLEVIEW
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    // FUNCTION THAT IS CALLED TO SET THE NUMBER OF ROWS IN THE TABLEVIEW
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempCategoryItems.count
    }

    
    // FUNCTION THAT IS CALLED TO STYLE THE TABLEVIEW CELL
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tempItem = tempCategoryItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecordTableViewCell
        cell.categoryLabel?.text = tempItem.categoryName
        cell.selectionStyle = .none
        return cell
    }
    
    
    // FUNCTION THAT IS CALLED TO STYLE AND CODE THE TABLEVIEW CELL SWIPE ACTION
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // TRASH ACTION
        let TrashAction = UIContextualAction(style: .normal, title:  "Löschen", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            print("Lösche \(self.tempCategoryItems[indexPath.row].categoryName)")
            // Delete the row from the data source
            self.tempCategoryItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
            success(true)
        })
        TrashAction.backgroundColor = .red
        
        // EDIT ACTION
        let FlagAction = UIContextualAction(style: .normal, title:  "Bearbeiten", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("Editing \(self.tempCategoryItems[indexPath.row].categoryName)")
            //self.showInputToEdit(index: indexPath)
            self.showInputToEdit(index: indexPath)
            success(true)
        })
        FlagAction.backgroundColor = CategoryColors.NavbarBlue
        
        
        return UISwipeActionsConfiguration(actions: [TrashAction, FlagAction])
    }
    
    
    // FUNCTION THAT IS CALLED TO EDIT EXISTING ITEM IN TABLEVIEW VIA SWIPE GESTURE
    func showInputToEdit(index: IndexPath) {
        let alertController = UIAlertController(title: "Item bearbeiten", message: "Bitte passe ggf. den Namen an.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Speichern", style: .default) { (_) in
            
            // getting the input values from user
            let name = alertController.textFields?[0].text
            if alertController.textFields?[0].text != "" {
                self.updateTodoItem(index: index, name: name!, isDone: false)
            }
            else {
                print("Name ist leer")
                self.showInputWhenNameWasEmpty()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel) { (_) in }
        
        // adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Name..."
            textField.text = self.tempCategoryItems[index.row].categoryName
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // FUNCTION THAT IS CALLED TO UPDATE AN ITEM
    func updateTodoItem(index: IndexPath,name: String, isDone: Bool) {
        tempCategoryItems[index.row].categoryName = name
        tableView.reloadData()
    }
    
    // FUNCTION THAT IS CALLED TO SHOW AN ERROR ALERT WHEN INPUT WAS EMPTY
    func showInputWhenNameWasEmpty() {
        let alertController = UIAlertController(title: "Neue Aufgabe", message: "Der Name der Aufgabe darf nicht leer sein!", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Hinzufügen", style: .default) { (_) in
            
            //getting the input values from user
            if alertController.textFields?[0].text != "" {
                self.showInputDialog()
            }
            else {
                print("Name ist leer")
                self.showInputWhenNameWasEmpty()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel) { (_) in }
        
        // adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Name..."
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
 
}

