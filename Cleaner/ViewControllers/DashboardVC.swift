//
//  MainVC.swift
//  Cleaner
//
//  Created by Hao on 10/2/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit
class MainVC: UIViewController{
    
    @IBOutlet weak var speedButton: UIButton!
    @IBOutlet weak var wifiButton: UIButton!
    @IBOutlet weak var boostButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var pieChartView: PieChartView!
    
    @IBOutlet weak var freePercentLabel: UILabel!
    @IBOutlet weak var freeSpaceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let deviceServices = DeviceServices()
        pieChartView.addItem(value: 100 - Float(deviceServices.diskFreePercent) , color: UIColor.red)
        pieChartView.addItem(value: Float(deviceServices.diskFreePercent) , color: UIColor.clear)
        freePercentLabel.text = "\(Int(deviceServices.diskFreePercent)) %"
        let freeSize = ByteCountFormatter.string(fromByteCount: Int64(deviceServices.diskFree), countStyle: .file)
        freeSpaceLabel.text = "\(freeSize)"
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func bootButton(_ sender: UIButton) {
    }
    
    @IBAction func openSideMenu(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: NotificationName.toggleMenu, object: nil)
    }
    
    
}
