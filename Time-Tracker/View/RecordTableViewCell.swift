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
        self.displayLoadingIndicator(displayedMessage: "Bitte warten ...")
        
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
                    self.dismissLoadingIndicator(animated: true)
                    print("Document data already exists!")
                    self.displayAlertWithOkBtn(title: "Fehler beim Speichern", message: "Es existiert bereits ein Datensatz für \n''\(docRef.documentID)'' \nin der Datenbank!")
                } else {
                    docRef.setData([
                        "name": name,
                        "hasRecords": hasRecords,
                        "recordedTime": recordedTime,
                        "createdAt": FieldValue.serverTimestamp()
                        ], completion: { (error: Error?) in
                            if let error = error {
                                self.dismissLoadingIndicator(animated: true)
                                print("Error while saving into DB... \(error.localizedDescription)")
                            }
                            else {
                                self.dismissLoadingIndicator(animated: true)
                                print("DB Transfer successfull.")
                                //self.displayAlertWithOkBtn(title: "Daten wurden gespeichert", message: "Die Daten wurden erfolgreich in die DB gespeichert.")
                                self.getDataFS(name: name)
                            }
                    })
                }
            }
        }
        self.getDataFS(name: name)
    }
    
    
    // FUNCTION THAT IS CALLED TO SET TIMESTAMP
    func getDataFromDB(name: String){
        db.collection("\(dbCollection) (\(getShortDate()))").document(name).getDocument { (document, error) in
            
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//                print("Document data: \(dataDescription)")
                print("\(document.documentID) => \(document.data())")
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func getDataFS(name: String){
        //let ref = db.collection("\(dbCollection) (\(getShortDate()))").whereField("hasRecords", isEqualTo: true)
        let ref = db.collection("\(dbCollection) (\(getShortDate()))").document(name)
        ref.getDocument { (docSnapshot, error) in
            guard let docSnapshot = docSnapshot, docSnapshot.exists else { return }
            let myData = docSnapshot.data()
            let itemName = myData!["name"] as? String ?? ""
            let itemTime = myData!["recordedTime"] as? String ?? ""
            let itemCreationDate = myData!["createdAt"] as? String ?? ""
            //print("Name: \(itemName) \nRecorded time: \(itemTime) \nCreated at: \(itemCreationDate) ")
            let msg = "'\(itemName)' erfolgreich in DB geschrieben.\nAufgezeichnete Zeit: \(itemTime) \nAngelegt am: \(itemCreationDate)"
            self.displayAlertWithOkBtn(title: "Daten wurden gespeichert", message: msg)
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
    
    
    // FUNCTION THAT IS CALLED TO BUID AN ALERT WITH OK BUTTON
    private func displayAlertWithOkBtn(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Okay", style: .default, handler: { _ in })
        alert.addAction(alertAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        //self.present(alert, animated: true, completion: nil)
    }
    
    
    // FUNCTION THAT IS CALLED TO SHOW LOADING INDICATOR
    private func displayLoadingIndicator(displayedMessage: String){
        let alert = UIAlertController(title: nil, message: displayedMessage, preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    
    // FUNCTION THAT IS CALLED TO DISMISS A LOADING INDICATOR
    private func dismissLoadingIndicator(animated: Bool){
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.stopAnimating()
        
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: animated, completion: nil)
    }
    
}
