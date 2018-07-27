//
//  RecordTableViewCell.swift
//  Time-Tracker
//
//  Created by Alessandro Orlandi on 26.07.18.
//  Copyright © 2018 Alessandro Orlandi. All rights reserved.
//

import UIKit

class RecordTableViewCell: UITableViewCell {
    
    var timer: Timer!
    var totalTime = "1:15 Std."
    var isRecording = false
    var time = 0

    // Tableview Cell Outlets
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryTimeLabel: UILabel!
    @IBOutlet weak var categoryActionButton: UIButton!
    
    @IBAction func recordTimeHandler(_ sender: UIButton) {
        buttonPressed()
    }
    
    
    @objc func buttonPressed() {
        print("Bool when Button is pressed \(isRecording)")
        toggleButton(bool: !isRecording)
    }
    
    
    func toggleButton(bool: Bool){
        isRecording = bool
        switch isRecording {
        case true:
            startTimer()
        case false:
            stopTimer()
        }
    }
    
    
    func startTimer(){
        print("startTimer called... isRecording = \(isRecording)")
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimeLabel), userInfo: nil, repeats: true)
    }
    
    
    @objc func updateTimeLabel(){
        print("updateTimeLabel() called...")
        categoryActionButton.setImage(#imageLiteral(resourceName: "pauseIcon"), for: .normal)
        time += 1
        self.categoryTimeLabel.text = "\(timeFormatted(time))"
    }
    
    
    func stopTimer(){
        print("stopTimer() called...")
        categoryActionButton.setImage(#imageLiteral(resourceName: "playIcon"), for: .normal)
        timer.invalidate()
    }
    
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hours: Int = (totalSeconds / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }


}
