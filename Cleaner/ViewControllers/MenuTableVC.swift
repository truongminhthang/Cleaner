//
//  MenuTableVC.swift
//  Cleaner
//
//  Created by Hao on 10/7/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit

class MenuTableVC: UITableViewController {
    @IBOutlet weak var memoryLabel: UILabel!
    
    @IBOutlet weak var storageLabel: UILabel!
    
    @IBOutlet weak var cpuLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let convertUsed = String(format: "%.1f", DeviceServices.shared.memoryUsedPercent)
        memoryLabel.text = "\(convertUsed) %"
        let convertStorage = String(format: "%.1f", DeviceServices.shared.diskUsedPercent)
        storageLabel.text = "\(convertStorage) %"
         let convertCPU = String(format: "%.1f", DeviceServices.shared.cpuUsedSize)
        cpuLabel.text = "\(convertCPU) %"
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
   
    @IBAction func closeSideMenu() {
        NotificationCenter.default.post(name: notificationKey, object: nil)
        tableView.reloadData()
    }

}
