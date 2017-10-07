//
//  ExtensionGradientColor.swift
//  Cleaner
//
//  Created by Hao on 10/2/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: View {
    
    @IBInspectable var startColor:   UIColor = .black { didSet { layoutSubviews() }}
    @IBInspectable var endColor:     UIColor = .white { didSet { layoutSubviews() }}
    @IBInspectable var startLocation: Double =   0.05 { didSet { layoutSubviews() }}
    @IBInspectable var endLocation:   Double =   0.95 { didSet { layoutSubviews() }}
    @IBInspectable var horizontalMode:  Bool =  false { didSet { layoutSubviews() }}
    @IBInspectable var diagonalMode:    Bool =  false { didSet { layoutSubviews() }}
    
    override class var layerClass: AnyClass { return CAGradientLayer.self }
    var gradientLayer: CAGradientLayer { return layer as! CAGradientLayer }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePoints()
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
        gradientLayer.colors    = [startColor.cgColor, endColor.cgColor]
    }
    
    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? CGPoint(x: 1, y: 0) : CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? CGPoint(x: 0, y: 0) : CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? CGPoint(x: 1, y: 1) : CGPoint(x: 0.5, y: 1)
        }
    }
    
}
