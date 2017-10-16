//
//  ViewController.swift
//  Cleaner
//
//  Created by Truong Thang on 10/2/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit
import SystemEye

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
        let meroryUsed = (Memory.systemUsage().active + Memory.systemUsage().compressed + Memory.systemUsage().wired)
        let memoryFree = (Memory.systemUsage().free + Memory.systemUsage().inactive)
        let percentUsed = meroryUsed/Memory.systemUsage().total * 100
        let percentFree = memoryFree/Memory.systemUsage().total * 100
        let used = String(format: "%.1f", percentFree)
        let free = String(format: "%.1f", percentUsed)
        self.memoryUsedLabel.text = ByteCountFormatter.string(fromByteCount: Int64(meroryUsed), countStyle: .file)
        self.memoryFreeLabel.text = ByteCountFormatter.string(fromByteCount: Int64(memoryFree), countStyle: .file)
        self.percentMUsed.text = "\(free) %"
        self.percentMemoryUsed.text = "\(used) %"
        
        self.percentMemoryFree.text = "\(free)"
    }
    
}

