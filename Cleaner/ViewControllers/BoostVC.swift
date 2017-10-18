//
//  ViewController.swift
//  Cleaner
//
//  Created by Truong Thang on 10/2/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit

class BoostVC: UIViewController {
    
    @IBOutlet weak var percentMemoryUsed: UILabel!
    @IBOutlet weak var percentMemoryFree: UILabel!
    @IBOutlet weak var memoryFreeLabel: UILabel!
    @IBOutlet weak var memoryUsedLabel: UILabel!
    
    @IBOutlet weak var percentMUsed: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickAndRunBoost(_ sender: UIButton) {
        
        self.memoryUsedLabel.text = ByteCountFormatter.string(fromByteCount: Int64(DeviceServices.shared.memoryUsedSize), countStyle: .file)
        self.memoryFreeLabel.text = ByteCountFormatter.string(fromByteCount: Int64(DeviceServices.shared.memoryFreeSize), countStyle: .file)
        let convertUsed = String(format: "%.1f", DeviceServices.shared.memoryUsedPercent)
        let convertFree = String(format: "%.1f", DeviceServices.shared.memoryFreePercent)
        self.percentMUsed.text = "\(convertUsed) %"
        self.percentMemoryUsed.text = "\(convertFree) %"
        self.percentMemoryFree.text = "\(convertUsed)"
    }
    
}

