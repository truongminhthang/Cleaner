//
//  MenuTableVC.swift
//  Cleaner
//
//  Created by Hao on 10/7/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit
import StoreKit

class MenuTableVC: UITableViewController {
    @IBOutlet weak var memoryLabel: UILabel!
    
    @IBOutlet weak var storageLabel: UILabel!
    
    @IBOutlet weak var cpuLabel: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        memoryLabel.text = "\(SystemServices.shared.memoryUsage(inPercent: true).memoryUsed) %"
        storageLabel.text = "\(SystemServices.shared.diskSpaceUsage(inPercent: true).useDiskSpace) %"
        cpuLabel.text = "\(SystemServices.shared.cpuUsage()) %"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            reviewUs(url: "itms-apps://itunes.apple.com/app/id(ID_APP)?action=write-review")
        }
    }
    
    private func reviewUs(url: String) {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else if let urlAppStore = URL(string: url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(urlAppStore, options: [:])
            }
            else {
                UIApplication.shared.openURL(urlAppStore)
            }
        }
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
