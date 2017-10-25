//
//  ViewController.swift
//  Cleaner
//
//  Created by Truong Thang on 10/2/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit
import GoogleMobileAds
class BoostVC: UIViewController,CAAnimationDelegate {
    
    // - Mark : Properties
    @IBOutlet weak var smallerView: GradientView!
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var viewMain: View!
    @IBOutlet weak var coverButton: Button!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var biggestCircle: GradientView!
    @IBOutlet weak var sweepView: GradientView!
    @IBOutlet weak var percentMemoryUsed: CountingLabel!
    @IBOutlet weak var percentMemoryFree: CountingLabel!
    @IBOutlet weak var memoryFreeLabel: CountingLabel!
    @IBOutlet weak var memoryUsedLabel: CountingLabel!
    @IBOutlet weak var percentMemoryFreeMain: CountingLabel!
    
    var timer = Timer()
    var gradientLayer: CAGradientLayer!
    var colorSets = [[CGColor]]()
    var currentColorSet: Int!
    let freeMemoryPercent  = String(format: "%.f", DeviceServices.shared.memoryFreePercent)
    let usedMemoryPercent  = String(format: "%.f", DeviceServices.shared.memoryUsedPercent)
    override func viewDidLoad() {
        super.viewDidLoad()
        GoogleAdMob.sharedInstance.initializeBannerView()
        sweepView.backgroundColor = UIColor.clear
        // Do any additional setup after loading the view, typically from a nib.
         changeValue()
        self.createColorSets()
        self.createGradientLayer()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(BoostVC.clickAndRunBoost(_:)))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GoogleAdMob.sharedInstance.hideBannerView()
    }
   
    // - Mark : Active
    func changeValue(){
        if SharedUserDefaults.shared.a == 0 {
            self.percentMemoryFreeMain.text = "\(SharedUserDefaults.shared.memoryFreePercentFake) %"
            self.percentMemoryFree.text = "\(SharedUserDefaults.shared.memoryFreePercentFake)"
            self.percentMemoryUsed.text = "\(100.0 - SharedUserDefaults.shared.memoryFreePercentFake) %"
            self.memoryFreeLabel.text = ByteCountFormatter.string(fromByteCount: Int64(SharedUserDefaults.shared.memoryFreeFake), countStyle: .binary)
            self.memoryUsedLabel.text = ByteCountFormatter.string(fromByteCount: Int64(SharedUserDefaults.shared.memoryUsedFake), countStyle: .binary)
            SharedUserDefaults.shared.a = 1
            print(SharedUserDefaults.shared.a)
        } else {
            self.percentMemoryFreeMain.text = "\(self.freeMemoryPercent) %"
            self.percentMemoryUsed.text = "\(self.usedMemoryPercent) %"
            self.memoryFreeLabel.text = ByteCountFormatter.string(fromByteCount: Int64(DeviceServices.shared.memoryFreeSize), countStyle: .binary)
            self.memoryUsedLabel.text = ByteCountFormatter.string(fromByteCount: Int64(DeviceServices.shared.memoryUsedSize), countStyle: .binary)
            self.percentMemoryFree.text = freeMemoryPercent
        }
    }
    
    @IBAction func clickAndRunBoost(_ sender: UIButton) {
        
        UIView.animate(withDuration: 3.0, delay: 0, options: [.repeat, .curveLinear] , animations: {
            self.moveRight(view: self.sweepView)
            self.changeLabel.textColor = UIColor.darkGray
            self.percentMemoryFree.textColor = UIColor.darkGray
            self.changeLabel.text = "⇊MEMORY DOWN⇊"
            self.changeAlpha(label: self.changeLabel)
            self.handleTapGesture()
            self.percentMemoryFree.count(fromValue: 100.0, to: DeviceServices.shared.memoryUsedPercent, withDuration: 4, andAnimationType: .EaseOut, andCounterType: .Int)
        }) { (_) in
            self.moveLeft(view: self.sweepView)
            self.smallerView.startColor = UIColor.blue
        }
        self.sweepView.backgroundColor = UIColor(red: 248/255, green: 210/255, blue: 230/255, alpha: 0.7)
        self.stackView.isHidden = true
        self.coverButton.isHidden = true
        timer = Timer.scheduledTimer(timeInterval: 7, target: self, selector: #selector(BoostVC.runBoost), userInfo: nil, repeats: false)
    }
}

