//
//  RecordTableViewCell.swift
//  Time-Tracker
//
//  Created by Alessandro Orlandi on 26.07.18.
//  Copyright © 2018 Alessandro Orlandi. All rights reserved.
//

import UIKit
import FirebaseFirestore

class RecordTableViewCell: UITableViewCell {
    
    // CUSTOM VARIABLES
    var timer: Timer!
    var isRecording = false
    var time = 0
    
    
    // FIREBASE VARIABLES
    let db = Firestore.firestore()
    let settings = FirestoreSettings()
    let dbCollection = "Items"
    //var timestamp = Timestamp()
    
    
    // TABLEVIEW CELL OUTLETS
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryTimeLabel: UILabel!
    @IBOutlet weak var categoryActionButton: UIButton!
    @IBAction func recordTimeHandler(_ sender: UIButton) {
        buttonPressed()
    }
    
//    private func getShortDate() -> String {
//        let dateFormatter = DateFormatter()
//        let date = Date()
//        dateFormatter.dateFormat = "dd.MM.yyyy"
//        return  dateFormatter.string(from: date)
//    }
    
    
    override func awakeFromNib() {
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    
    // FUNCTION THAT IS CALLED TO PUSH DATA IN TO DB
    func saveAfterCheckToDB(name: String, recordedTime: String){
        let docRef = db.collection("\(dbCollection) (\(Utilities.formatDate()))").document(name)
        // Displaying Loading-Indicator
        Utilities.displayLoadingIndicator(displayedMessage: "Bitte warten ...")
        // Check if Item has a recorded time
        let hasRecords: Bool
        if recordedTime == "00:00:00"{
            hasRecords = false
            print("hasRecords is false")
        } else {
            hasRecords = true
        }
        docRef.getDocument { (document, error) in
            if let document = document {
                if document.exists {
                    // Handle case, that the document already exists in DB
                    let time: String = document.get("recordedTime") as! String
                    // Check if recorded time changed
                    if time != recordedTime {
                        docRef.setData([
                            "name": name,
                            "hasRecords": hasRecords,
                            "recordedTime": recordedTime,
                            "createdAt": FieldValue.serverTimestamp()
                            ], completion: { (error: Error?) in
                                if let error = error {
                                    Utilities.dismissLoadingIndicator(animated: true)
                                    print("Error while saving into DB... \(error.localizedDescription)")
                                }
                                else {
                                    Utilities.dismissLoadingIndicator(animated: true)
                                    print("DB Transfer successfull.")
                                    self.showInsertedDataFromDB(name: name, isItAnUpdate: true)
                                }
                        })
                    } else {
                        Utilities.dismissAlert()
                        Utilities.dismissLoadingIndicator(animated: true)
                        print("Document data already exists!")
                        Utilities.displayAlertWithOkBtn(title: "Fehler beim Speichern", message: "Es existiert bereits ein Datensatz für \n''\(docRef.documentID)'' \nin der Datenbank!")
                    }
                    
                } else {
                    docRef.setData([
                        "name": name,
                        "hasRecords": hasRecords,
                        "recordedTime": recordedTime,
                        "createdAt": FieldValue.serverTimestamp()
                        ], completion: { (error: Error?) in
                            if let error = error {
                                Utilities.dismissLoadingIndicator(animated: true)
                                print("Error while saving into DB... \(error.localizedDescription)")
                            }
                            else {
                                Utilities.dismissLoadingIndicator(animated: true)
                                print("DB Transfer successfull.")
                                
                                self.showInsertedDataFromDB(name: name, isItAnUpdate: false)
                            }
                    })
                }
            }
        }
        // Call after datas successfully saved into DB
        self.showInsertedDataFromDB(name: name, isItAnUpdate: false)
        
    }
    
    
    // FUNCTION THAT IS CALLED TO GET A SINGLE ITEM FROM DB
    func showInsertedDataFromDB(name: String, isItAnUpdate: Bool){
        let ref = db.collection("\(dbCollection) (\(Utilities.formatDate()))").document(name)
        ref.getDocument { (docSnapshot, error) in
            guard let docSnapshot = docSnapshot, docSnapshot.exists else { return }
            let timestamp: Timestamp = (docSnapshot.get("createdAt") as? Timestamp)!
            let name: String = docSnapshot.get("name") as! String
            let time: String = docSnapshot.get("recordedTime") as! String
            let date: Date = timestamp.dateValue()
            let msg: String
            
            if isItAnUpdate {
                msg = "Daten erfolgreich in DB aktualisiert.\nName: \(name)\nAufgezeichnete Zeit: \(time)\nAngelegt am \(Utilities.formatTimestampGetDate(date: date)) \nAngelegt um \(Utilities.formatTimestampGetTime(date: date)) Uhr"
                Utilities.displayAlertWithOkBtn(title: "Daten wurden aktualisiert", message: msg)
            } else {
                msg = "Daten erfolgreich in DB geschrieben.\nName: \(name)\nAufgezeichnete Zeit: \(time)\nAngelegt am \(Utilities.formatTimestampGetDate(date: date)) \nAngelegt um \(Utilities.formatTimestampGetTime(date: date)) Uhr"
                Utilities.displayAlertWithOkBtn(title: "Daten wurden gespeichert", message: msg)
            }
            
            
        }
    }
    
    
    // FUNCTION THAT IS CALLED TO GET A SINGLE ITEM FROM DB
    func showSavedDataFromDB(name: String){
        let ref = db.collection("\(dbCollection) (\(Utilities.formatDate()))").document(name)
        ref.getDocument { (docSnapshot, error) in
            guard let docSnapshot = docSnapshot, docSnapshot.exists else { return }
            let timestamp: Timestamp = (docSnapshot.get("createdAt") as? Timestamp)!
            let name: String = docSnapshot.get("name") as! String
            let time: String = docSnapshot.get("recordedTime") as! String
            let date: Date = timestamp.dateValue()
            let msg: String
            msg = "Daten erfolgreich in DB geschrieben.\nName: \(name)\nAufgezeichnete Zeit: \(time)\nAngelegt am \(Utilities.formatTimestampGetDate(date: date)) \nAngelegt um \(Utilities.formatTimestampGetTime(date: date)) Uhr"
            Utilities.displayAlertWithOkBtn(title: "Daten wurden gespeichert", message: msg)
        }
    }
    
    
    // FUNCTION THAT IS CALLED TO GET A SINGLE ITEM FROM DB
    func showUpdatedDataFromDB(name: String){
        let ref = db.collection("\(dbCollection) (\(Utilities.formatDate()))").document(name)
        ref.getDocument { (docSnapshot, error) in
            guard let docSnapshot = docSnapshot, docSnapshot.exists else { return }
            let timestamp: Timestamp = (docSnapshot.get("createdAt") as? Timestamp)!
            let name: String = docSnapshot.get("name") as! String
            let time: String = docSnapshot.get("recordedTime") as! String
            let date: Date = timestamp.dateValue()
            let msg = "Daten erfolgreich in DB aktualisiert.\nName: \(name)\nAufgezeichnete Zeit: \(time)\nAngelegt am \(Utilities.formatTimestampGetDate(date: date)) \nAngelegt um \(Utilities.formatTimestampGetTime(date: date)) Uhr"
            Utilities.displayAlertWithOkBtn(title: "Daten aktualisiert", message: msg)
        }
    }
    
  
    // FUNCTION THAT IS CALLED, WHEN PLAY/PAUSE BUTTON IS PRESSED
    @objc func buttonPressed() {
        toggleButton(bool: !isRecording)
    }
    
    
    // FUNCTION THAT IS CALLED, AFTER BUTTONPRESSED-FUNCTION EXECUTED, TO TOGGLE BOOL AND BUTTON IMAGE
    func toggleButton(bool: Bool){
        isRecording = bool
        isRecording ? startTimer() : stopTimer()
    }
    
    
    // FUNCTION THAT IS CALLED, TO FIRE THE TIMER IN TABLEVIEW CELL
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimeLabel), userInfo: nil, repeats: true)
    }
    
    
    // FUNCTION THAT IS CALLED EVERY SECOND, TO UPDATE TIME-LABEL IN TABLEVIEW CELL
    @objc func updateTimeLabel(){
        time += 1
        self.categoryTimeLabel.text = "\(timeFormatted(time))"
        categoryActionButton.setImage(#imageLiteral(resourceName: "pauseIcon"), for: .normal)
        self.backgroundColor = CategoryColors.NavbarBlue
    }
    
    
    // FUNCTION THAT IS CALLED, TO STOP THE TIMER
    func stopTimer(){
        categoryActionButton.setImage(#imageLiteral(resourceName: "playIcon"), for: .normal)
        timer.invalidate()
        self.backgroundColor = nil
    }
    
    
    // FUNCTION THAT IS CALLED TO FORMATT TIME-LABEL IN HH:MM:SS
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hours: Int = (totalSeconds / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
}
