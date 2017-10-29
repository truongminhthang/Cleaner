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
    
    var memoryFreeDefault: Double = 0
    var percentMemoryUse: Double = 0
    var percentMemoryUseDefault: Double = 0
    
    var isWhileRun:Bool = true {
        didSet {
            if isWhileRun {
                self.changeLabel.textColor = UIColor.darkGray
                self.percentMemoryFree.textColor = UIColor.darkGray
                self.changeLabel.text = "⇊MEMORY DOWN⇊"
                self.percentMemoryFree.count(fromValue: 100.0, to: percentMemoryUse, withDuration: 4, andAnimationType: .EaseOut, andCounterType: .Int)
                self.sweepView.backgroundColor = UIColor(red: 248/255, green: 210/255, blue: 230/255, alpha: 0.7)
                self.stackView.isHidden = true
                self.coverButton.isEnabled = false
            } else {
                self.changeLabel.text = "MEMORY FREE"
                self.changeLabel.textColor = UIColor.red
                self.percentMemoryFree.textColor = UIColor.red
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
            setDisplayMemoryFree(memoryFree: 0, percentMemoryFree: 0, isFake: true)
        } else {
            setDisplayMemoryFree(memoryFree: SystemServices.shared.memoryUsage(inPercent: false).memoryFree.rounded(toPlaces: 3), percentMemoryFree: SystemServices.shared.memoryUsage(inPercent: true).memoryFree.rounded(toPlaces: 3), isFake: false)
        }
        self.createColorSets()
        self.createGradientLayer()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(BoostVC.clickAndRunBoost(_:)))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        memoryFreeDefault = SystemServices.shared.memoryUsage(inPercent: false).memoryFree.rounded(toPlaces: 2)
        percentMemoryUseDefault = SystemServices.shared.memoryUsage(inPercent: true).memoryUsed.rounded(toPlaces: 2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        isFakeMode = true
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
        let memoryFreeCurrent: Double = SystemServices.shared.memoryUsage(inPercent: false).memoryFree
        let memoryFreeCurrentResult = memoryFreeCurrent > memoryFreeDefault ? memoryFreeCurrent.rounded(toPlaces: 2) : memoryFreeDefault.rounded(toPlaces: 2)
        let percentMemoryFreeCurrentResult = (memoryFreeCurrentResult * 100 / SystemServices.shared.memoryUsage(inPercent: false).totalMemory).rounded(toPlaces: 2)
        if AppDelegate.shared.isFakeModeApp {
            memoryUseClear = memoryFreeCurrentResult - SharedUserDefaults.shared.memoryFreeFake.rounded(toPlaces: 2)
        } else {
            memoryUseClear =  memoryFreeCurrent > memoryFreeDefault ? memoryFreeCurrent - memoryFreeDefault : memoryFreeDefault - memoryFreeCurrent
        }
        let dispatchTime = DispatchTime.now() + DispatchTimeInterval.seconds(7)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            self.runBoost(memoryUseClear: memoryUseClear, memoryFreeCurrent: memoryFreeCurrentResult, percentMemoryFreeCurrent: percentMemoryFreeCurrentResult)
        }
    }
    
    func setDisplayMemoryFree(memoryFree: Double,percentMemoryFree: Double, isFake: Bool) {
        if isFake {
            self.percentMemoryFree.text = "\(SharedUserDefaults.shared.memoryFreePercentFake)"
            self.percentMemoryFreeMain.text = "\(SharedUserDefaults.shared.memoryFreePercentFake) %"
            self.percentMemoryUsed.text = "\(100 - SharedUserDefaults.shared.memoryFreePercentFake) %"
            self.memoryFreeLabel.text = ByteCountFormatter.string(fromByteCount: Int64(SharedUserDefaults.shared.memoryFreeFake), countStyle: .binary)
            self.memoryUsedLabel.text = ByteCountFormatter.string(fromByteCount: Int64(SharedUserDefaults.shared.memoryUsedFake), countStyle: .binary)
        } else {
            self.percentMemoryFree.text = "\(percentMemoryFree)"
            self.percentMemoryFreeMain.text = "\(percentMemoryFree) %"
            self.percentMemoryUsed.text = "\(100 - percentMemoryFree) %"
            self.memoryFreeLabel.text = ByteCountFormatter.string(fromByteCount: Int64(memoryFree), countStyle: .binary)
            self.memoryUsedLabel.text = ByteCountFormatter.string(fromByteCount: Int64(SystemServices.shared.memoryUsage(inPercent: false).totalMemory - memoryFree), countStyle: .binary)
        }
    }
}

