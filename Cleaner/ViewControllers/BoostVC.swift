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
    let freeMemoryMain = String(format: "%.2f", DeviceServices.shared.memoryFreePercent)
    let freeMemoryPercent  = String(format: "%.1f", DeviceServices.shared.memoryFreePercent)
    let usedMemoryPercent  = String(format: "%.1f", DeviceServices.shared.memoryUsedPercent)
    var isWhileRun:Bool = true {
        didSet {
            if isWhileRun {
                self.changeLabel.textColor = UIColor.darkGray
                self.percentMemoryFree.textColor = UIColor.darkGray
                self.changeLabel.text = "⇊MEMORY DOWN⇊"
                let number = Double(Int(DeviceServices.shared.memoryUsedPercent*100))/100.0
                self.percentMemoryFree.count(fromValue: 100.0, to: number, withDuration: 4, andAnimationType: .EaseOut, andCounterType: .Int)
                self.sweepView.backgroundColor = UIColor(red: 248/255, green: 210/255, blue: 230/255, alpha: 0.7)
                self.stackView.isHidden = true
                self.coverButton.isEnabled = false
            } else {
                self.stackView.isHidden = false
                self.coverButton.isEnabled = true
            }
        }
    }
        var isFakeMode : Bool = true {
        didSet {
        if AppDelegate.shared.isFakeModeApp {
        self.percentMemoryFreeMain.text = "\(SharedUserDefaults.shared.memoryFreePercentFake) %"
        self.percentMemoryFree.text = "\(SharedUserDefaults.shared.memoryFreePercentFake)"
        self.percentMemoryUsed.text = "\(100.0 - SharedUserDefaults.shared.memoryFreePercentFake) %"
        self.memoryFreeLabel.text = ByteCountFormatter.string(fromByteCount: Int64(SharedUserDefaults.shared.memoryFreeFake), countStyle: .binary)
        self.memoryUsedLabel.text = ByteCountFormatter.string(fromByteCount: Int64(SharedUserDefaults.shared.memoryUsedFake), countStyle: .binary)
        AppDelegate.shared.isFakeModeApp = false
        } else {
        self.percentMemoryFreeMain.text = "\(self.freeMemoryPercent) %"
        self.percentMemoryUsed.text = "\(self.usedMemoryPercent) %"
        self.memoryFreeLabel.text = ByteCountFormatter.string(fromByteCount: Int64(DeviceServices.shared.memoryFreeSize), countStyle: .binary)
        self.memoryUsedLabel.text = ByteCountFormatter.string(fromByteCount: Int64(DeviceServices.shared.memoryUsedSize), countStyle: .binary)
        self.percentMemoryFree.text = freeMemoryMain
        }
        }
        }
        override func viewDidLoad() {
        super.viewDidLoad()
        GoogleAdMob.sharedInstance.initializeBannerView()
        sweepView.backgroundColor = UIColor.clear
        // Do any additional setup after loading the view, typically from a nib.
        isFakeMode = true
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
        @IBAction func clickAndRunBoost(_ sender: UIButton) {
        isWhileRun = true
        UIView.animate(withDuration: 3.0, delay: 0, options: [.repeat, .curveLinear] , animations: {
        self.moveRight(view: self.sweepView)
        self.changeAlpha(label: self.changeLabel)
        self.handleTapGesture()
        }) { (_) in
        self.moveLeft(view: self.sweepView)
        self.smallerView.startColor = UIColor.blue
        }
        timer = Timer.scheduledTimer(timeInterval: 7, target: self, selector: #selector(BoostVC.runBoost), userInfo: nil, repeats: false)
        }
}

