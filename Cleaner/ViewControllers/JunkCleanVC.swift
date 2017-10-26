//
//  JunkCleanVC.swift
//  Cleaner
//
//  Created by Hao on 10/2/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit

class JunkCleanVC: UIViewController,CAAnimationDelegate {
    
    @IBOutlet weak var middleView: View!
    @IBOutlet weak var biggerView: View!
    @IBOutlet weak var UnderView: GradientView!
    @IBOutlet weak var AboveView: GradientView!
    @IBOutlet weak var freeDiskLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var coverButton: Button!
    @IBOutlet weak var SpaceLabel: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        showAlert(vc: self, title: "nothing", message: "nothing")
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(JunkCleanVC.chosenAll))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        self.freeDiskLabel.text  = ByteCountFormatter.string(fromByteCount: Int64(SystemServices.shared.diskSpaceUsage(inPercent: false).freeDiskSpace), countStyle: .binary)
        self.createColorSets()
        self.createGradientLayer()
        
        
    }
    func showAlert(vc: UIViewController, title:String, message: String) {
        let alertController = UIAlertController (title: "Title", message: "Go to Settings?", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: "App-Prefs:root=General&path=Keyboard") else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    @IBAction func clickAndRunBoost(_ sender: UIButton) {
        self.chosenAll()
        self.SpaceLabel.isHidden = true
        self.availableLabel.isHidden = true
        coverButton.isHidden = true
        UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .curveLinear] , animations: {
            self.changeAlpha(label: self.changeLabel)
            self.changeAlpha(label: self.markLabel)
            self.changeLabel.text = "Đang lấy dữ liệu .... Vui lòng chờ"
        }) { (_) in
            
        }
        UIView.animate(withDuration: 2, delay: 0, options: [.repeat, .curveLinear] , animations: {
            self.changeAlpha(label: self.freeDiskLabel)
            self.freeDiskLabel.text = "Loading ..."
        }) { (_) in
            
        }
        
    }
    
    
}



