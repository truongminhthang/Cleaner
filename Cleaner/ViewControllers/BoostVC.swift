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
         GoogleAdMob.sharedInstance.initializeBannerView()
        // Do any additional setup after loading the view, typically from a nib.
        self.percentMemoryFree.text = "\(SystemServices.shared.memoryUsage(inPercent: true).memoryFree)"
        self.percentMUsed.text = "\(SystemServices.shared.memoryUsage(inPercent: true).memoryFree) %"
        self.percentMemoryUsed.text = "\(SystemServices.shared.memoryUsage(inPercent: true).memoryUsed) %"
        
        self.memoryFreeLabel.text = ByteCountFormatter.string(fromByteCount: Int64(SystemServices.shared.memoryUsage(inPercent: false).memoryFree), countStyle: .binary)
        self.memoryUsedLabel.text = ByteCountFormatter.string(fromByteCount: Int64(SystemServices.shared.memoryUsage(inPercent: false).memoryUsed), countStyle: .binary)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
         GoogleAdMob.sharedInstance.hideBannerView()
       
    }
    
    @IBAction func clickAndRunBoost(_ sender: UIButton) {
        
        
    }
    
}

