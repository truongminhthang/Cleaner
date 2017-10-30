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
    @IBOutlet weak var displayedInfoCircle: GradientView!
    @IBOutlet weak var infoStageLabel: UILabel!
    @IBOutlet weak var boostButton: Button!
    @IBOutlet weak var diplayedInfoCircleContainer: GradientView!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var infoUsedMemoryPercentLabel: CountingLabel!
    @IBOutlet weak var subinfoFreeMemoryLabel: CountingLabel!
    @IBOutlet weak var subinfoUsedMemoryLabel: CountingLabel!
    @IBOutlet weak var subinfoFreeMemoryPercentLabel: CountingLabel!
    @IBOutlet weak var subInfoUsedMemoryPercentLabel: CountingLabel!
    @IBOutlet var runningEffectView: GradientView!
    var gradientLayer: CAGradientLayer!
    var colorSets = [[CGColor]]()
    var currentColorSet: Int!
    var usedMemory = SystemServices.shared.memoryUsage(inPercent: false).memoryUsed
    var usedMemoryDisplay = 0.0 {
        didSet {
            let totalMemory = SystemServices.shared.memoryUsage(inPercent: false).totalMemory
            let usedMemoryPercent = usedMemoryDisplay / totalMemory * 100
            let freeMemory = totalMemory - usedMemoryDisplay
            let freeMemoryPercent = 100.0 - usedMemoryPercent
            
            self.infoUsedMemoryPercentLabel.text = "\(usedMemoryPercent.rounded(toPlaces: 2))"
            
            self.subinfoFreeMemoryPercentLabel.text = "\(freeMemoryPercent.rounded(toPlaces: 2)) %"
            self.subinfoFreeMemoryLabel.text = ByteCountFormatter.string(fromByteCount: Int64(freeMemory), countStyle: .file)
            
            self.subInfoUsedMemoryPercentLabel.text = "\(usedMemoryPercent.rounded(toPlaces: 2)) %"
            self.subinfoUsedMemoryLabel.text = ByteCountFormatter.string(fromByteCount: Int64(usedMemoryDisplay), countStyle: .file)
        }
    }
    
    
    var isRunning:Bool = true {
        didSet {
            infoStageLabel.text = isRunning ? "⇊MEMORY DOWN⇊" : "MEMORY USAGE"
            infoStageLabel.textColor = isRunning ? UIColor.gray : UIColor.blue
            infoUsedMemoryPercentLabel.textColor = isRunning ? UIColor.gray : UIColor.blue
            percentLabel.textColor =  isRunning ? UIColor.gray : UIColor.blue
            self.boostButton.isEnabled = !isRunning
            self.runningEffectView.isHidden = !isRunning
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
    
    var memoryShouldClear: Double = 0.0
    
    var memoryUsageFake: Double {
        return SystemServices.shared.memoryUsage(inPercent: false).memoryUsed + memoryShouldClear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRunningEffectView()
        memoryShouldClear = isFirstTimeMode ? Double(arc4random() %  UInt32(SystemServices.shared.memoryUsage(inPercent: false).memoryFree * 0.3)) : Double(arc4random() %  UInt32(SystemServices.shared.memoryUsage(inPercent: false).memoryFree * 0.05))
        GoogleAdMob.sharedInstance.initializeBannerView()
        usedMemoryDisplay = memoryUsageFake
       
    }
    
    func setupRunningEffectView() {
        runningEffectView.frame = CGRect(x: 0, y: 0, width: 500, height: 100)
        displayedInfoCircle.insertSubview(runningEffectView, at: 0)
        self.runningEffectView.transform = CGAffineTransform(translationX: 0, y: -200)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GoogleAdMob.sharedInstance.hideBannerView()
        timer?.invalidate()
        timer = nil
    }
    
    // - Mark : Active
    @IBAction func clickAndRunBoost(_ sender: UIButton) {
        isRunning = true
        showRunningEffect()
        timer = Timer.scheduledTimer(timeInterval: 0.005, target: self, selector: #selector(fakeReduceMemory), userInfo: nil, repeats: true)
    }
    
    @objc func fakeReduceMemory() {
        let jumpStep = 215000.0
        guard usedMemoryDisplay > usedMemory + jumpStep else {
            boostFinish()
            return
        }
        DispatchQueue.main.async {
            self.usedMemoryDisplay -= jumpStep
        }
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
        usedMemoryDisplay = usedMemory
        let clearnMemoryCount = memoryShouldClear
        let memoryOut = ByteCountFormatter.string(fromByteCount: Int64(clearnMemoryCount), countStyle: .binary)
        showAlert(vc: self, title: "Complete", message: "We have liberate \(memoryOut) in memory")
        memoryShouldClear = 0
        isFirstTimeMode = false

    }
}

