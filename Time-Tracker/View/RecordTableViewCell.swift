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
    var time: Int = 0
    
    
    
    
    // FIREBASE VARIABLES
    let db = Firestore.firestore()
    let settings = FirestoreSettings()
    let dbCollection = "Items"
    
    
    
    
    // TABLEVIEW CELL OUTLETS
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryTimeLabel: UILabel!
    @IBOutlet weak var categoryActionButton: UIButton!
    @IBAction func recordTimeHandler(_ sender: UIButton) {
        buttonPressed()
    }
    
    
    
    
    override func awakeFromNib() {
        settings.areTimestampsInSnapshotsEnabled = true
    }
    
    
    
    
    // FUNCTION THAT IS CALLED TO WRITEINTO
    func saveAfterCheckToDB(name: String, recordedTime: String, timer: Int) {
        
        // Creating new write batch
        let batch = db.batch()
        
        // Start showing Loading Indicator
        Utilities.displayLoadingIndicator(displayedMessage: "Bitte warten...")
        
        // Check if Item has a recorded time
        let hasRecords: Bool
        if recordedTime == "00:00:00"{
            hasRecords = false
            print("hasRecords is false")
        } else {
            hasRecords = true
        }
        
        // Creating Document Reference
        let docRef = db.collection(Utilities.getCurrentYear()).document(Utilities.getCurrenMonth()).collection(Utilities.getCurrentDay()).document(name)
        
        // Accessing DB now
        docRef.getDocument { (document, error) in
            if let doc = document {
                if doc.exists {
                    print("Document already exists, updateData called...")
                    Utilities.dismissLoadingIndicator(animated: true)
                    batch.updateData(
                        [
                            "timer": timer,
                            "name": name,
                            "hasRecords": hasRecords,
                            "recordedTime": recordedTime,
                            "lastUpdate": FieldValue.serverTimestamp()
                        ], forDocument: docRef)
                }
                else {
                    print("Document not existing, setData called...")
                    Utilities.dismissLoadingIndicator(animated: true)
                    batch.setData(
                        [
                            "timer": timer,
                            "name": name,
                            "hasRecords": hasRecords,
                            "recordedTime": recordedTime,
                            "createdAt": FieldValue.serverTimestamp(),
                            "lastUpdate": FieldValue.serverTimestamp()
                        ], forDocument: docRef)
                }
            }
            batch.commit(completion: { (error) in
                if let error = error {
                    print("Error while writing batch \(error.localizedDescription)")
                    Utilities.displayAlertWithOkBtn(title: "DB Fehler", message: "\(error.localizedDescription)")
                }
                else {
                    print("Batch successfully written!")
                    Utilities.displayAlertWithOkBtn(title: "Übertragung erfolgreich", message: "Die Daten wurden erfolgreich in die Datenbank übertragen")
                }
            })
        }
    }
    
    
    
    
    // FUNCTION THAT IS CALLED TO GET A SINGLE ITEM FROM DB
    func showInsertedDataFromDB(name: String, isItAnUpdate: Bool){
        let ref = db.collection("\(dbCollection) (\(Utilities.formatDate()))").document(name)
        ref.getDocument { (docSnapshot, error) in
            guard let docSnapshot = docSnapshot, docSnapshot.exists else { return }
            let timestamp: Timestamp = docSnapshot.get("createdAt") as! Timestamp
            let name: String = docSnapshot.get("name") as! String
            let time: String = docSnapshot.get("recordedTime") as! String
            let lastUpdate: Timestamp = docSnapshot.get("lastUpdate") as! Timestamp
            let timestampDate: Date = timestamp.dateValue()
            let lastUpdateDate: Date = lastUpdate.dateValue()
            let msg: String
            
            if isItAnUpdate {
                msg = "Daten erfolgreich in DB aktualisiert.\nName: \(name)\nAufgezeichnete Zeit: \(time)\nAngelegt am \(Utilities.formatTimestampGetDate(date: timestampDate)) \nAngelegt um \(Utilities.formatTimestampGetTime(date: timestampDate)) Uhr \nLetztes Update: \(Utilities.formatTimestampGetDate(date: lastUpdateDate))"
                Utilities.displayAlertWithOkBtn(title: "Daten wurden aktualisiert", message: msg)
            } else {
                msg = "Daten erfolgreich in DB geschrieben.\nName: \(name)\nAufgezeichnete Zeit: \(time)\nAngelegt am \(Utilities.formatTimestampGetDate(date: timestampDate)) \nAngelegt um \(Utilities.formatTimestampGetTime(date: timestampDate)) Uhr"
                Utilities.displayAlertWithOkBtn(title: "Daten wurden gespeichert", message: msg)
            }
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
    
    
    
    
    // FUNCTION IS CALLED TO GET TIME VALUE FOR TIMER
    func getTimeValue(){
        
        // Creating Document Reference
        let colRef = db.collection(Utilities.getCurrentYear()).document(Utilities.getCurrenMonth()).collection(Utilities.getCurrentDay())
        
        colRef.getDocuments { (snapshot, err) in
            if let err = err {
                Utilities.displayAlertWithOkBtn(title: "Fehler", message: "Ein Fehler ist aufgetreten: \n\(err.localizedDescription)")
            }
            else {
                for document in snapshot!.documents {
                    var time = document.data()["timer"] as? Int
                    self.time = time!
                    time = time! + 1
                }
            }
        }
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
