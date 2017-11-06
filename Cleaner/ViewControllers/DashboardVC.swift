//
//  MainVC.swift
//  Cleaner
//
//  Created by Hao on 10/2/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit
class DashboardVC: UIViewController{
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var freePercentLabel: UILabel!
    @IBOutlet weak var freeSpaceLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SystemServices.shared.updateAll()
        pieChartView.removeAllItem()
        pieChartView.addItem(value: Float(SystemServices.shared.diskSpace.usedPercent) , color: UIColor.red)
        pieChartView.addItem(value: Float(SystemServices.shared.diskSpace.freePercent) , color: UIColor.clear)
        freePercentLabel.text = "\(SystemServices.shared.diskSpace.freePercent) %"
        freeSpaceLabel.text = SystemServices.shared.diskSpace.free.fileSizeString
        clearButton.isSelected = true
        GoogleAdMob.sharedInstance.isBannerDisplay = false
        AppDelegate.shared.isDashboardDisplay = true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openSideMenu(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: Notification.Name.toggleMenu, object: nil)
    }
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        AppDelegate.shared.isDashboardDisplay = false
       GoogleAdMob.sharedInstance.toogleBanner()
    }
    
    
    
}
