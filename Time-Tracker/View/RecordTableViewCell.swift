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
    //let timestamp: Timestamp
    //let date: Date
    //timestamp = DocumentSnapshot.get("created_at") as! Timestamp
    //date = timestamp.dateValue()
    
    let db = Firestore.firestore()
    let settings = FirestoreSettings()
    let dbCollection = "Items"
    
    override func awakeFromNib() {
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }

    
    // TABLEVIEW CELL OUTLETS
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryTimeLabel: UILabel!
    @IBOutlet weak var categoryActionButton: UIButton!
    @IBAction func recordTimeHandler(_ sender: UIButton) {
        buttonPressed()
    }
    
    private func getShortDate() -> String {
        let dateFormatter = DateFormatter()
        let date = Date()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return  dateFormatter.string(from: date)
    }
    
    
    // FUNCTION THAT IS CALLED TO PUSH DATA IN TO DB
    func saveAfterCheckToDB(name: String, recordedTime: String){
        
        let hasRecords: Bool
        
        if recordedTime == "00:00:00"{
            hasRecords = false
        } else {
            hasRecords = true
        }
        
        let docRef = db.collection("\(dbCollection) (\(getShortDate()))").document(name)
        docRef.getDocument { (document, error) in
            if let document = document {
                if document.exists {
                    print("Document data already exists!")
                } else {
                    docRef.setData([
                        "name": name,
                        "hasRecords": hasRecords,
                        "recordedTime": recordedTime,
                        "createdAt": "not done yet"
                        ], completion: { (error: Error?) in
                            if let error = error {
                                print("Error while saving into DB... \(error.localizedDescription)")
                            }
                            else {
                                print("DB Transfer successfull.")
                            }
                    })
                }
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
