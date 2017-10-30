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
        SystemServices.shared.updateMemoryUsage()
        memoryLabel.text = "\((SystemServices.shared.memoryState.memoryUsed / SystemServices.shared.memoryState.totalMemory * 100).rounded(toPlaces: 2)) %"
        storageLabel.text = "\(SystemServices.shared.diskSpaceUsage(inPercent: true).useDiskSpace) %"
        cpuLabel.text = "\(SystemServices.shared.cpuUsage()) %"
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
        NotificationCenter.default.post(name: NotificationName.toggleMenu, object: nil)
        tableView.reloadData()
    }

}
