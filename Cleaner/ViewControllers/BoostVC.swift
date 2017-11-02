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
    @IBOutlet weak var gaugeView: GaugeView!
    @IBOutlet weak var displayPieChartView: PieChartView!
    @IBOutlet weak var displayedInfoCircle: GradientView!
    @IBOutlet weak var diplayedInfoCircleContainer: PieChartView!
    @IBOutlet weak var infoStageLabel: UILabel!
    @IBOutlet weak var boostButton: Button!
    @IBOutlet weak var percentLabel: UILabel!
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
    var memoryState : MemoryState = {
        SystemServices.shared.updateMemoryUsage()
        return SystemServices.shared.memoryState
    }()
    var usedMemoryDisplay = 0.0 {
        didSet {
            let totalMemory = memoryState.totalMemory
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
            if isRunning {
                infoStageLabel.text = "⇊MEMORY DOWN⇊"
                infoStageLabel.textColor = UIColor.gray
                infoUsedMemoryPercentLabel.textColor = UIColor.gray
                percentLabel.textColor = UIColor.gray
                self.boostButton.isEnabled = !isRunning
                self.runningEffectView.isHidden = !isRunning
                displayPieChartView.isHidden = true
                diplayedInfoCircleContainer.isHidden = false
            } else {
                infoStageLabel.text = "MEMORY USAGE"
                infoStageLabel.textColor = UIColor.blue
                infoUsedMemoryPercentLabel.textColor = UIColor.blue
                percentLabel.textColor = UIColor.blue
                let usedMemoryPercent = usedMemoryDisplay / memoryState.totalMemory * 100
                self.diplayedInfoCircleContainer.addItem(value: Float(usedMemoryPercent), color: UIColor.blue)
                self.diplayedInfoCircleContainer.addItem(value: Float(100 - usedMemoryPercent), color: UIColor.white)
                self.diplayedInfoCircleContainer.setNeedsDisplay()
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
    
    var memoryShouldClear: Double = 0.0
    
    var memoryUsageFake: Double {
        return memoryState.memoryUsed + memoryShouldClear
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        gaugeView.percentage = Float(value)
        setupRunningEffectView()
        memoryShouldClear = isFirstTimeMode ? Double(arc4random() %  UInt32(memoryState.memoryUsed * 0.3)) : Double(arc4random() %  UInt32(memoryState.memoryFree * 0.05))
        usedMemoryDisplay = memoryUsageFake
        let usedMemoryPercent = usedMemoryDisplay / memoryState.totalMemory * 100
        displayPieChartView.addItem(value: Float(usedMemoryPercent), color: UIColor.red)
        displayPieChartView.addItem(value: Float(100 - usedMemoryPercent), color: UIColor.white)
        displayPieChartView.setNeedsDisplay()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
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
            timers = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(repeatFire), userInfo: nil, repeats: true)
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
        let jumpStep = 525000.0
        guard usedMemoryDisplay > memoryState.memoryUsed + jumpStep else {
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
        gaugeView.isHidden = true
        timer?.invalidate()
        timer = nil
        runningEffectView.removeFromSuperview()
        boostButton.isEnabled = true
        usedMemoryDisplay = memoryState.memoryUsed
        isRunning = false
        let clearnMemoryCount = memoryShouldClear
        let memoryOut = ByteCountFormatter.string(fromByteCount: Int64(clearnMemoryCount), countStyle: .binary)
        showAlert(title: "Complete", message: "We have liberate \(memoryOut) in memory", completeHandler: {
            GoogleAdMob.sharedInstance.showInterstitial()
        })
        memoryShouldClear = 0
        isFirstTimeMode = false
        boostButton.setTitle("RUN AGAIN", for: .normal)
    }
    // create repeat view
    @objc func repeatFire(){
        if valueAdd > 0 {
            valueAdd -= 1
            UIView.animate(withDuration: 1 , delay: 1, options: .curveLinear, animations: {
                self.valueUp(view: self.gaugeView)
            }) { (_) in
                self.valueDown(view: self.gaugeView)
            }
            
        } else {
            timer?.invalidate()
        }
    }
    func valueUp(view: GaugeView) {
        view.percentage += 100
    }
    func valueDown(view : GaugeView) {
        view.percentage += 0
    }
    
}

