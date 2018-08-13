//
//  Utilities.swift
//  Time-Tracker
//
//  Created by Alessandro Orlandi on 06.08.18.
//  Copyright © 2018 Alessandro Orlandi. All rights reserved.
//

import Foundation
import UIKit

enum Utilities {
    
    
    
    
    // FUNCTION THAT IS CALLED TO GET THE CURRENT YEAR
    static func getCurrentYear() -> String {
        let dateFormatter = DateFormatter()
        let date = Date()
        dateFormatter.dateFormat = "yyyy"
        return  dateFormatter.string(from: date)
    }
    
    
    
    
    // FUNCTION THAT IS CALLED TO GET THE CURRENT MONTH
    static func getCurrenMonth() -> String {
        let dateFormatter = DateFormatter()
        let date = Date()
        dateFormatter.dateFormat = "MMMM"
        return  dateFormatter.string(from: date)
    }
    
    
    
    
    static func helper() -> String {
        let dateFormatter = DateFormatter()
        let date = Date()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        return  dateFormatter.string(from: date)
    }
    
    
    
    
    // FUNCTION THAT IS CALLED TO GET THE CURRENT DAY
    static func getCurrentDay() -> String {
        let dateFormatter = DateFormatter()
        let date = Date()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return  dateFormatter.string(from: date)
    }
    
    
    
    
    // FUNCTION THAT IS CALLED TO GET THE CURRENT DAY AND DATE
    static func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        let date = Date()
        //dateFormatter.dateFormat = "EEEE, dd.MM.yyyy"
        dateFormatter.dateFormat = "EEE, dd.MM.yy"
        return  dateFormatter.string(from: date)
    }
    
    
    
    
    // FUNCTION THAT IS CALLED TO FORMAT TIMESTAMP VALUE
    static func formatTimestampGetDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return  dateFormatter.string(from: date)
    }
    
    
    
    
    // FUNCTION THAT IS CALLED TO FORMAT TIMESTAMP VALUE
    static func formatTimestampGetTime(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return  dateFormatter.string(from: date)
    }
    
    
    
    
    // FUNCTION THAT IS CALLED TO FORMAT DATE in dd.MM.yyyy Format
    static func formatDate() -> String {
        let dateFormatter = DateFormatter()
        let date = Date()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return  dateFormatter.string(from: date)
    }
    
    
    
    
    // FUNCTION THAT IS CALLED TO BUID AN ALERT WITH OK BUTTON
    static func displayAlertWithOkBtn(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: { _ in })
        alert.addAction(alertAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    // FUNCTION THAT IS CALLED TO DISMISS AN ALERT VIEW
    static func dismissAlert(){
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    // FUNCTION THAT IS CALLED TO SHOW LOADING INDICATOR
    static func displayLoadingIndicator(displayedMessage: String){
        
        dismissAlert()
        
        let alert = UIAlertController(title: nil, message: displayedMessage, preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    // FUNCTION THAT IS CALLED TO DISMISS A LOADING INDICATOR
    static func dismissLoadingIndicator(animated: Bool){
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.stopAnimating()
        
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: animated, completion: nil)
    }
    
}


