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

    override func viewDidLoad() {
        super.viewDidLoad()

        
        tempCategoryItems = [
            CategoryItem(categoryColor: UIColor.brown, categoryName: "Test mich", recordedTime: "0:05h", actionButton: #imageLiteral(resourceName: "Play")),
            CategoryItem(categoryColor: UIColor.blue, categoryName: "Noch ein Test", recordedTime: "1:15h", actionButton: #imageLiteral(resourceName: "Play")),
            CategoryItem(categoryColor: UIColor.red, categoryName: "Der letzte Test", recordedTime: "0:00h", actionButton: #imageLiteral(resourceName: "Play"))]
        

        
        self.tabBarItem = UITabBarItem(title: "Erfassen", image: #imageLiteral(resourceName: "Play"), tag: 0)
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempCategoryItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tempItem = tempCategoryItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecordTableViewCell
        cell.categoryColorView?.backgroundColor = tempItem.categoryColor
        cell.categoryColorView.layer.cornerRadius = 3
        cell.categoryLabel?.text = tempItem.categoryName
        cell.categoryTimeLabel?.text = tempItem.recordedTime
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
 
}
