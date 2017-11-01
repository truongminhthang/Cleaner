//
//  JunkCleanVC.swift
//  Cleaner
//
//  Created by Hao on 10/2/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit

class JunkCleanVC: UIViewController,CAAnimationDelegate {
    
    @IBOutlet weak var displayPieChartView: PieChartView!
    @IBOutlet weak var gaugeView: GaugeView!
    @IBOutlet weak var middleView: PieChartView!
    @IBOutlet weak var biggerView: View!
    @IBOutlet weak var UnderView: GradientView!
    @IBOutlet weak var AboveView: GradientView!
    @IBOutlet weak var freeDiskLabel: UILabel!
    @IBOutlet weak var displayInfoLabel: UILabel!
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var boostCleanButton: Button!
    @IBOutlet weak var SpaceLabel: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    
    // Mark: Properties
    var timer = Timer()
    var value = 0
    var valueAdd = 150
    var gradient: CAGradientLayer!
    var gradientLayer: CAGradientLayer!
    var colorSets = [[CGColor]]()
    var currentColorSet: Int!
    var hander : Bool = true {
        didSet{
            if currentColorSet < colorSets.count - 1 {
                currentColorSet! += 1
            }
            else {
                currentColorSet = 0
            }
            let colorChangeAnimation = CABasicAnimation(keyPath: "colors")
            colorChangeAnimation.repeatCount = 100
            colorChangeAnimation.duration = 3.0
            colorChangeAnimation.toValue = colorSets[currentColorSet]
            colorChangeAnimation.fillMode = kCAFillModeForwards
            colorChangeAnimation.isRemovedOnCompletion = false
            colorChangeAnimation.delegate = self
            gradient.add(colorChangeAnimation, forKey: "color")
        }
    }
    var storeageReduce: Double = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        gaugeView.percentage = Float(value)
        self.freeDiskLabel.text  = ByteCountFormatter.string(fromByteCount: Int64(SystemServices.shared.diskSpaceUsage(inPercent: false).freeDiskSpace), countStyle: .binary)
        storeageReduce = SystemServices.shared.diskSpaceUsage(inPercent: false).freeDiskSpace
        middleView.backgroundColor = UIColor.clear
        let freeDiskSpacePercent = SystemServices.shared.diskSpaceUsage(inPercent: true).freeDiskSpace
        displayPieChartView.addItem(value: 100 - Float(freeDiskSpacePercent), color: UIColor.red)
        displayPieChartView.addItem(value: Float(SystemServices.shared.diskSpaceUsage(inPercent: true).freeDiskSpace), color: UIColor.white)
        displayPieChartView.setNeedsDisplay()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.createColorSets()
        self.createGradientLayer()
    }
    // Mark: Clear Cache Memory
    func clearTempFolder() {
        let fileManager = FileManager.default
        let tempFolderPath = NSTemporaryDirectory()
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: tempFolderPath)
            for filePath in filePaths {
                try fileManager.removeItem(atPath: tempFolderPath + filePath)
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
    var isNeedToChange: Bool = true {
        didSet {
            if isNeedToChange {
                self.SpaceLabel.isHidden = true
                self.availableLabel.isHidden = true
                biggerView.backgroundColor = UIColor.clear
                self.displayInfoLabel.text = " Getting the data .... Please wait!"
                self.freeDiskLabel.text = "    Loading ...    "
                boostCleanButton.isEnabled = false
                self.displayPieChartView.isHidden = true
            } else {
                let systemChange = SystemServices.shared.diskSpaceUsage(inPercent: false).freeDiskSpace > storeageReduce ? SystemServices.shared.diskSpaceUsage(inPercent: false).freeDiskSpace - storeageReduce : storeageReduce - SystemServices.shared.diskSpaceUsage(inPercent: false).freeDiskSpace
                let systemReduce = ByteCountFormatter.string(fromByteCount: Int64(systemChange), countStyle: .binary)
                let storageChange = SystemServices.shared.diskSpaceUsage(inPercent: false).freeDiskSpace > storeageReduce ? SystemServices.shared.diskSpaceUsage(inPercent: false).freeDiskSpace :
                storeageReduce
                self.freeDiskLabel.alpha = 1
                self.displayInfoLabel.text = " Complete"
                self.freeDiskLabel.text  = ByteCountFormatter.string(fromByteCount: Int64(storageChange), countStyle: .binary)
                self.SpaceLabel.isHidden = false
                self.availableLabel.isHidden = false
                let freeDiskSpacePercent = SystemServices.shared.diskSpaceUsage(inPercent: true).freeDiskSpace
                self.middleView.addItem(value: 100 - Float(freeDiskSpacePercent), color: UIColor.red)
                self.middleView.addItem(value: Float(SystemServices.shared.diskSpaceUsage(inPercent: true).freeDiskSpace), color: UIColor.white)
                middleView.setNeedsDisplay()
                boostCleanButton.isEnabled = true
                boostCleanButton.setTitle("FINISH", for: .normal)
                showAlertToDeleteApp(title: "Do you want go to setting manage?", message: "The process is complete! Storage reduced \(systemReduce) but some items with private content can not be removed!")
            }
        }
    }
    // Mark: Active
    @IBAction func clickAndRunBoost(_ sender: UIButton) {
        if sender.currentTitle == "CLEAN" {
            self.chosenAll()
            clearTempFolder()
            isNeedToChange = true
            UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .curveLinear] , animations: {
                self.changeAlpha(label: self.displayInfoLabel)
                self.changeAlpha(label: self.markLabel)
            }) { (_) in
            }
            UIView.animate(withDuration: 2, delay: 0, options: [.repeat, .curveLinear] , animations: {
                self.changeAlpha(label: self.freeDiskLabel)
            }) { (_) in
            }
            timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector:#selector(repeatFire), userInfo: nil, repeats: true)
            let dispatchTime = DispatchTime.now() + DispatchTimeInterval.seconds(7)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                self.runBoost()
            }
        } else {
            showAlert(title: "Complete", message: "Storage has been refreshed")
        }
    }
    // - create active when finish
    @objc func runBoost() {
        isNeedToChange = false
    }
    // - create repeat view
    @objc func repeatFire(){
        if valueAdd > 0 {
            valueAdd -= 1
            UIView.animate(withDuration: 1 , delay: 1, options: .curveLinear, animations: {
                self.valueUp(view: self.gaugeView)
            }) { (_) in
                self.valueDown(view: self.gaugeView)
            }
        } else {
            timer.invalidate()
        }
    }
    func valueUp(view: GaugeView) {
        view.percentage += 100
    }
    func valueDown(view : GaugeView) {
        view.percentage += 0
    }
}



