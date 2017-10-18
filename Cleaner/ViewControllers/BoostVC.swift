//
//  ViewController.swift
//  Cleaner
//
//  Created by Truong Thang on 10/2/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit
import GoogleMobileAds
class BoostVC: UIViewController {
    
    @IBOutlet weak var percentMemoryUsed: UILabel!
    @IBOutlet weak var percentMemoryFree: UILabel!
    @IBOutlet weak var memoryFreeLabel: UILabel!
    @IBOutlet weak var memoryUsedLabel: UILabel!
    
    @IBOutlet weak var percentMUsed: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        let freeMemoryPercent  = String(format: "%.1f", DeviceServices.shared.memoryFreePercent)
        self.percentMemoryFree.text = freeMemoryPercent
        self.percentMUsed.text = "\(freeMemoryPercent) %"
         let usedMemoryPercent  = String(format: "%.1f", DeviceServices.shared.memoryUsedPercent)
        self.percentMemoryUsed.text = "\(usedMemoryPercent) %"
        
        self.memoryFreeLabel.text = ByteCountFormatter.string(fromByteCount: Int64(DeviceServices.shared.memoryFreeSize), countStyle: .file)
        self.memoryUsedLabel.text = ByteCountFormatter.string(fromByteCount: Int64(DeviceServices.shared.memoryUsedSize), countStyle: .file)

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickAndRunBoost(_ sender: UIButton) {
        
        
    }
    
}

