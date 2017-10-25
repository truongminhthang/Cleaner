//
//  SweepView.swift
//  Cleaner
//
//  Created by Hao on 10/24/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import Foundation
import UIKit
extension BoostVC {
// Custom sweepview
    
    func changeAlpha(label: UILabel) {
        label.alpha = 0.2
    }
    
    func moveRight(view: UIView) {
        view.center.y += 300
    }
    
    func moveLeft(view: UIView) {
        view.center.y -= 300
    }
    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.viewMain.bounds
        
        gradientLayer.colors = colorSets[currentColorSet]
        
        self.viewMain.layer.addSublayer(gradientLayer)
    }
    
    func createColorSets() {
        colorSets.append([UIColor.init(red: 255/255, green: 211/255, blue: 212/255, alpha: 0.7).cgColor, UIColor.init(red: 255/255, green: 211/255, blue: 212/255, alpha: 0.7).cgColor])
        colorSets.append([UIColor.init(red: 248/255, green: 3/255, blue: 123/255, alpha: 0.7).cgColor, UIColor.init(red: 255/255, green: 211/255, blue: 212/255, alpha: 0.7).cgColor])
        colorSets.append([UIColor.init(red: 255/255, green: 211/255, blue: 212/255, alpha: 0.7).cgColor, UIColor.init(red: 248/255, green: 3/255, blue: 123/255, alpha: 0.7).cgColor])
        currentColorSet = 0
    }
    

    // Mark: Active
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            gradientLayer.colors = colorSets[currentColorSet]
        }
    }
    @objc func handleTapGesture() {
        if currentColorSet < colorSets.count - 1 {
            currentColorSet! += 1
        }
        else {
            currentColorSet = 0
        }
        
        let colorChangeAnimation = CABasicAnimation(keyPath: "colors")
        colorChangeAnimation.repeatCount = 10
        colorChangeAnimation.duration = 3.0
        colorChangeAnimation.toValue = colorSets[currentColorSet]
        colorChangeAnimation.fillMode = kCAFillModeForwards
        colorChangeAnimation.isRemovedOnCompletion = false
        colorChangeAnimation.delegate = self
        gradientLayer.add(colorChangeAnimation, forKey: "colorChange")
    }
    
    // create alert
    func showAlert(vc: UIViewController, title:String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.navigationController?.popViewController(animated: true)
        }))
        vc.present(alertController, animated: true, completion: nil)
    }
    @objc func runBoost() {
        let memoryOut = ByteCountFormatter.string(fromByteCount: Int64(SharedUserDefaults.shared.memoryUsedFake - DeviceServices.shared.memoryUsedSize), countStyle: .binary)
        showAlert(vc: self, title: "Hoàn thành", message: "chúng tôi đã giải phóng \(memoryOut) trong bộ nhớ")
    }

}
