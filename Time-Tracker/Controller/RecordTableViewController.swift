//
//  RecordTableViewController.swift
//  Time-Tracker
//
//  Created by Alessandro Orlandi on 24.07.18.
//  Copyright © 2018 Alessandro Orlandi. All rights reserved.
//

import UIKit
import Crashlytics
import Firebase
import FirebaseFirestore

class RecordTableViewController: UITableViewController {
    
    
    
    
    // CUSTOM VARIABLES
    var tempCategoryItems = [CategoryItem]()
    var countdownTimer = [Timer]()
    var totalTime = 0
    
    
    
    
    // FIRESTORE
    lazy var db = Firestore.firestore()
    
    
    
    
    // VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseApp.configure()
        getDataFromDbAndAppendToArray()
        listenForChanges()

        self.title = Utilities.getCurrentDate()
        self.tableView.delaysContentTouches = false
        self.tabBarItem = UITabBarItem(title: "Erfassen", image: #imageLiteral(resourceName: "RecentIcon"), tag: 0)
    }
    
    
    
    
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
    
    
    
    
    // FUNCTION THAT IS CALLED TO LISTEN FOR CHANGES
    func listenForChanges(){
        db.collection(Utilities.getCurrentYear()).document(Utilities.getCurrenMonth()).collection(Utilities.getCurrentDay())
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                let name = documents.map { $0["name"]! }
                let recordedTime = documents.map {$0["recordedTime"]! }
                print("Current data: \(name, recordedTime)")
        }
    }

    
    
    
    // FUNCTION THAT IS CALLED TO GET DATA FROM DB AND APPEND IT TO ARRAY
    func getDataFromDbAndAppendToArray(){
        
        // Creating Document Reference
        let colRef = db.collection(Utilities.getCurrentYear()).document(Utilities.getCurrenMonth()).collection(Utilities.getCurrentDay())
        
        colRef.getDocuments { (snapshot, err) in
            if let err = err {
                Utilities.displayAlertWithOkBtn(title: "Fehler", message: "Ein Fehler ist aufgetreten: \n\(err.localizedDescription)")
            }
            else {
                for document in snapshot!.documents {
                    if let name = document.data()["name"] as? String {
                        if let recordedTime = document.data()["recordedTime"] as? String {
                            if let time = document.data()["timer"] as? Int {
                                print("Name = \(name) \nRecorded Time = \(recordedTime) \nTimer Value = \(time)")
                                self.tempCategoryItems.append(CategoryItem(name: name, recordedTime: recordedTime, time: time))
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    // FUNC IS CALLED TO SAVE AND UPDATE DATA INTO DB
    @IBAction func moveToFirebaseDB(_ sender: UIBarButtonItem) {
        let indexPathsArray = tableView.indexPathsForVisibleRows
        for indexPath in indexPathsArray! {
            let cell = tableView.cellForRow(at: indexPath) as! RecordTableViewCell
            cell.saveAfterCheckToDB(name: cell.categoryLabel.text!, recordedTime: cell.categoryTimeLabel.text!, timer: cell.time)
        }
    }
    
    
    
    
    // FUNCTION THAT IS CALLED TO ADD A NEW ITEM
    @IBAction func addNewItem(_ sender: UIBarButtonItem) {
        showInputDialog()
    }
    
    
    
    
    // FUNCTION THAT IS CALLED TO UPDATE AN ITEM
    func updateTodoItem(index: IndexPath,name: String, isDone: Bool) {
        tempCategoryItems[index.row].name = name
        tableView.reloadData()
    }
    
    
    
    
    // FUNCTION THAT IS CALLED TO SHOW DIALOG FOR NEW ITEM
    private func showInputDialog(){
        
        // Create Alert-Controller
        let alertController = UIAlertController(title: "Neue Kategorie", message: "Lege eine neue Kategorie an.", preferredStyle: .alert)
        
        // Add Textfield to Alert-Controller
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Name der Kategorie"
        }
        
        // Create "Save" Button with Logic-Part
        let saveAction = UIAlertAction(title: "Hinzufügen", style: .default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0].text
            if alertController.textFields![0].text != "" {
                //self.tempCategoryItems.append(CategoryItem(categoryName: firstTextField!, recordedTime: nil))
                self.tempCategoryItems.append(CategoryItem(name: firstTextField!, recordedTime: "00:00:00", time: 0))
                self.tableView.reloadData()
            } else {
                Utilities.displayAlertWithOkBtn(title: "Fehler beim Speichern", message: "Bitte gib einen Namen an.")
                return
            }
        })
        
        // Create "Cancel" Button
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .default, handler: { (action : UIAlertAction!) -> Void in })
        
        // Add Buttons to Alert-Controller
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true, completion: nil)
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
        
        print("Cell for Row at...")
        
        let tempItem = tempCategoryItems[indexPath.row]
        print(tempItem.name)
        print(tempItem.recordedTime)
        print(tempItem.time)
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecordTableViewCell
        cell.categoryLabel?.text = tempItem.name
        cell.categoryTimeLabel.text = tempItem.recordedTime
        cell.time = tempItem.time
        cell.selectionStyle = .none
        return cell
    }
    
    
    
    
    // FUNCTION THAT IS CALLED TO STYLE AND CODE THE TABLEVIEW CELL SWIPE ACTION
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // TRASH ACTION
        let TrashAction = UIContextualAction(style: .normal, title:  "Löschen", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            // Delete the row from the data source
            self.tempCategoryItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
            success(true)
        })
        TrashAction.backgroundColor = .red
        
        // EDIT ACTION
        let FlagAction = UIContextualAction(style: .normal, title:  "Bearbeiten", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("Editing \(self.tempCategoryItems[indexPath.row].name)")
            self.showInputToEdit(index: indexPath)
            success(true)
        })
        FlagAction.backgroundColor = CategoryColors.NavbarBlue
        
        // Adding the Buttons
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
            }
        }
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel) { (_) in }
        
        // adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Name..."
            textField.text = self.tempCategoryItems[index.row].name
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}

