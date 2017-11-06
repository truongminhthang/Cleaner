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
    
    // - Mark : Properties
    @IBOutlet weak var gauge: Gauge!
    @IBOutlet weak var displayedInfoCircle: GradientView!
    @IBOutlet weak var infoStageLabel: UILabel!
    @IBOutlet weak var boostButton: Button!
    @IBOutlet weak var infoUsedMemoryPercentLabel: UILabel!
    @IBOutlet weak var subinfoFreeMemoryLabel: UILabel!
    @IBOutlet weak var subinfoUsedMemoryLabel: UILabel!
    @IBOutlet weak var subinfoFreeMemoryPercentLabel: UILabel!
    @IBOutlet weak var subInfoUsedMemoryPercentLabel: UILabel!
    @IBOutlet var runningEffectView: GradientView!
    var colorSets = [[CGColor]]()
    var timers = Timer()
    var value = 0
    var valueAdd = 150
    var currentColorSet: Int!

    var memoryDisplay = Usage() {
        didSet {
            self.infoUsedMemoryPercentLabel.text = "\(memoryDisplay.freePercent)%"
            self.subinfoFreeMemoryPercentLabel.text = "\(memoryDisplay.freePercent) %"
            self.subinfoFreeMemoryLabel.text = memoryDisplay.free.fileSizeString
            self.subInfoUsedMemoryPercentLabel.text = "\(memoryDisplay.usedPercent) %"
            self.subinfoUsedMemoryLabel.text = memoryDisplay.used.fileSizeString
            self.gauge.rate = CGFloat(memoryDisplay.usedPercent / 10)
        }
    }

    var isRunning:Bool = false {
        didSet {
            if isRunning {
                infoStageLabel.text = "⇊MEMORY DOWN⇊"
                infoStageLabel.textColor = UIColor.gray
                infoUsedMemoryPercentLabel.textColor = UIColor.gray
                self.boostButton.isEnabled = !isRunning
                self.runningEffectView.isHidden = !isRunning
            } else {
                infoStageLabel.text = "MEMORY USAGE"
                infoStageLabel.textColor = UIColor.blue
                infoUsedMemoryPercentLabel.textColor = UIColor.blue
                self.gauge.startColor = UIColor.blue
            }
        }
    }
    var isFirstTimeMode : Bool {
        get {
            return AppDelegate.shared.isFakeModeApp
        }
        set {
            AppDelegate.shared.isFakeModeApp = newValue
        }
    }
    var timer : Timer?
    
    var memoryShouldClear: Double = 0.0 {
        didSet {
            memoryDisplay = Usage(free: SystemServices.shared.memory.free - memoryShouldClear, total: SystemServices.shared.memory.total)
        }
    }
    var clearnMemoryCount : Double = 0.0
   
    override func viewDidLoad() {
        super.viewDidLoad()
        SystemServices.shared.updateMemoryUsage()
        setupRunningEffectView()
        updateMemoryShouldClear()
        memoryDisplay = Usage(free: SystemServices.shared.memory.free - memoryShouldClear, total: SystemServices.shared.memory.total)
    }
    func updateMemoryShouldClear() {
        let percentMemoryShouldClear = isFirstTimeMode ?  0.3 : 0.1
        memoryShouldClear = Double(arc4random() %  UInt32(SystemServices.shared.memory.free * percentMemoryShouldClear))
        clearnMemoryCount = memoryShouldClear

    }
    
    func setupRunningEffectView() {
        runningEffectView.frame = CGRect(x: 0, y: 0, width: 500, height: 100)
        displayedInfoCircle.insertSubview(runningEffectView, at: 0)
        self.runningEffectView.transform = CGAffineTransform(translationX: 0, y: -300)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
        
    }
    
    // - Mark : Active
    @IBAction func clickAndRunBoost(_ sender: UIButton) {
        if sender.currentTitle == "BOOST MEMORY"
        {
            isRunning = true
            showRunningEffect()
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(fakeReduceMemory), userInfo: nil, repeats: true)
        } else {
            showAlert(title: "Complete", message: "We have liberate Zero KB in memory", completeHandler: {
                GoogleAdMob.sharedInstance.showInterstitial()
            })
        }
    }
    @objc func fakeReduceMemory() {
        let jumpStep = 200000.0
        guard self.memoryShouldClear > 0 else {
            memoryShouldClear = 0.0
            self.boostFinish()
            return
        }
        self.memoryShouldClear -= jumpStep
    }
    
    func showRunningEffect() {
        setupRunningEffectView()
        UIView.animate(withDuration: 3.0, delay: 0, options: [.repeat, .curveLinear] , animations: {
            self.runningEffectView.transform = CGAffineTransform(translationX: 0, y: 200)
        }) { (_) in
            // handle complete if need
        }
    }
    @objc func boostFinish() {
        timer?.invalidate()
        timer = nil
        runningEffectView.removeFromSuperview()
        boostButton.isEnabled = true
        isRunning = false
        showAlert(title: "Complete", message: "We have liberate \(clearnMemoryCount.fileSizeString) in memory", completeHandler: {
            GoogleAdMob.sharedInstance.showInterstitial()
        })
        memoryShouldClear = 0
        isFirstTimeMode = false
        boostButton.setTitle("RUN AGAIN", for: .normal)
    }
}

