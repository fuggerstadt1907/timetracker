//
//  RecordNavigationController.swift
//  Time-Tracker
//
//  Created by Alessandro Orlandi on 25.07.18.
//  Copyright © 2018 Alessandro Orlandi. All rights reserved.
//

import UIKit

class RecordNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
