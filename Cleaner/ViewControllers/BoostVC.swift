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
    @IBOutlet weak var viewNotmain: View!
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
    
    var percentMemoryUse: Double = 0
    var memoryUsedDefault: Double = 0
    var percentMemoryUseDefault: Double = 0
    
    var isWhileRun:Bool = true {
        didSet {
            if isWhileRun {
                self.changeLabel.textColor = UIColor.darkGray
                self.percentMemoryFree.textColor = UIColor.darkGray
                self.changeLabel.text = "⇊MEMORY DOWN⇊"
                self.viewNotmain.isHidden = true
                self.viewMain.isHidden = false
                self.percentMemoryFree.count(fromValue: 100.0, to: percentMemoryUse, withDuration: 4, andAnimationType: .EaseOut, andCounterType: .Int)
                self.sweepView.backgroundColor = UIColor(red: 248/255, green: 210/255, blue: 230/255, alpha: 0.7)
                self.stackView.isHidden = true
                self.coverButton.isEnabled = false
                self.sweepView.isHidden = false
            } else {
                self.sweepView.isHidden = true
                self.changeLabel.text = "MEMORY USED"
                self.viewNotmain.isHidden = false
                self.viewMain.isHidden = true
                self.changeLabel.textColor = UIColor.blue
                self.percentMemoryFree.textColor = UIColor.blue
                self.changeLabel.alpha = 1
                self.stackView.isHidden = false
                self.coverButton.isEnabled = true
            }
        }
    }
    var isFakeMode : Bool = true {
        didSet {
            if AppDelegate.shared.isFakeModeApp {
                AppDelegate.shared.isFakeModeApp = false
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        GoogleAdMob.sharedInstance.initializeBannerView()
        sweepView.backgroundColor = UIColor.clear
        // Do any additional setup after loading the view, typically from a nib.
        if AppDelegate.shared.isFakeModeApp {
            setDisplayMemory(memoryUsed: 0, percentMemoryUsed: 0, isFake: true)
        } else {
            setDisplayMemory(memoryUsed: SystemServices.shared.memoryUsage(inPercent: false).memoryUsed.rounded(toPlaces: 3), percentMemoryUsed: SystemServices.shared.memoryUsage(inPercent: true).memoryUsed.rounded(toPlaces: 3), isFake: false)
        }
        self.createColorSets()
        self.createGradientLayer()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(BoostVC.clickAndRunBoost(_:)))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        getMemory()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GoogleAdMob.sharedInstance.hideBannerView()
    }
    
    func getMemory() {
        percentMemoryUseDefault = SystemServices.shared.memoryUsage(inPercent: true).memoryUsed.rounded(toPlaces: 2)
        memoryUsedDefault = SystemServices.shared.memoryUsage(inPercent: false).memoryUsed.rounded(toPlaces: 2)
    }
    
    // - Mark : Active
    @IBAction func clickAndRunBoost(_ sender: UIButton) {
        var memoryUseClear: Double = 0
        percentMemoryUse = percentMemoryUseDefault > SystemServices.shared.memoryUsage(inPercent: true).memoryUsed.rounded(toPlaces: 2) ? SystemServices.shared.memoryUsage(inPercent: true).memoryUsed.rounded(toPlaces: 2) : percentMemoryUseDefault
        isWhileRun = true
        UIView.animate(withDuration: 3.0, delay: 0, options: [.repeat, .curveLinear] , animations: {
            self.moveRight(view: self.sweepView)
            self.changeAlpha(label: self.changeLabel)
            
            self.handleTapGesture()
        }) { (_) in
            self.moveLeft(view: self.sweepView)
            self.smallerView.startColor = UIColor.blue
        }
        let memoryUsedCurrent = SystemServices.shared.memoryUsage(inPercent: false).memoryUsed.rounded(toPlaces: 2)
        let memoryUsedCurrentResult = memoryUsedCurrent > memoryUsedDefault ? memoryUsedDefault : memoryUsedCurrent
        let percentMemoryUsedCurrentResult = (memoryUsedCurrentResult * 100 / SystemServices.shared.memoryUsage(inPercent: false).totalMemory).rounded(toPlaces: 2)
        
        if AppDelegate.shared.isFakeModeApp {
            memoryUseClear = SharedUserDefaults.shared.memoryUsedFake.rounded(toPlaces: 2) - memoryUsedCurrentResult
        } else {
            memoryUseClear =  memoryUsedCurrent > memoryUsedDefault ? memoryUsedCurrent - memoryUsedDefault : memoryUsedDefault - memoryUsedCurrent
        }
        let dispatchTime = DispatchTime.now() + DispatchTimeInterval.seconds(7)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            self.runBoost(memoryUseClear: memoryUseClear, memoryUsedCurrent: memoryUsedCurrentResult, percentMemoryUsedCurrent: percentMemoryUsedCurrentResult)
        }
        isFakeMode = true
    }
    
    func setDisplayMemory(memoryUsed: Double,percentMemoryUsed: Double, isFake: Bool) {
        if isFake {
            self.percentMemoryFree.text = "\(SharedUserDefaults.shared.memoryUsedPercentFake)"
            self.percentMemoryFreeMain.text = "\(100 - SharedUserDefaults.shared.memoryUsedPercentFake) %"
            self.percentMemoryUsed.text = "\(SharedUserDefaults.shared.memoryUsedPercentFake) %"
            self.memoryFreeLabel.text = ByteCountFormatter.string(fromByteCount: Int64(SharedUserDefaults.shared.memoryFreeFake), countStyle: .binary)
            self.memoryUsedLabel.text = ByteCountFormatter.string(fromByteCount: Int64(SharedUserDefaults.shared.memoryUsedFake), countStyle: .binary)
        } else {
            self.percentMemoryFree.text = "\(percentMemoryUsed.rounded(toPlaces: 1))"
            self.percentMemoryFreeMain.text = "\(100 - percentMemoryUsed) %"
            self.percentMemoryUsed.text = "\(percentMemoryUsed) %"
            self.memoryFreeLabel.text = ByteCountFormatter.string(fromByteCount: Int64(SystemServices.shared.memoryUsage(inPercent: false).totalMemory - memoryUsed), countStyle: .binary)
            self.memoryUsedLabel.text = ByteCountFormatter.string(fromByteCount: Int64(memoryUsed), countStyle: .binary)
        }
    }
}

