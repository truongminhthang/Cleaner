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

  
    
}
extension JunkCleanVC {
    func changeAlpha(label: UILabel) {
        label.alpha = 0
    }
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradient = CAGradientLayer()
        gradientLayer.frame = self.AboveView.bounds
        gradient.frame = self.UnderView.bounds
        gradient.colors = colorSets[currentColorSet]
        gradientLayer.colors = colorSets[currentColorSet]
        
        self.AboveView.layer.addSublayer(gradient)
        self.UnderView.layer.addSublayer(gradientLayer)
    }
    
    func createColorSets() {
        colorSets.append([UIColor.init(red: 255/255, green: 211/255, blue: 212/255, alpha: 0.7).cgColor, UIColor.init(red: 255/255, green: 211/255, blue: 212/255, alpha: 0.7).cgColor])
        colorSets.append([UIColor.init(red: 248/255, green: 3/255, blue: 123/255, alpha: 0.7).cgColor, UIColor.init(red: 255/255, green: 211/255, blue: 212/255, alpha: 0.7).cgColor])
        colorSets.append([UIColor.init(red: 255/255, green: 211/255, blue: 212/255, alpha: 0.7).cgColor, UIColor.init(red: 248/255, green: 3/255, blue: 123/255, alpha: 0.7).cgColor])
        currentColorSet = 0
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
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            gradientLayer.colors = colorSets[currentColorSet]
            gradient.colors = colorSets[currentColorSet]
        }
    }
    @objc func chosenAll() {
        self.biggerView.backgroundColor = UIColor.clear
        self.middleView.backgroundColor = UIColor.clear
        self.handleTapGesture()
        self.hander = !self.hander
    }
}
