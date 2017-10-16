//
//  gaugeView.swift
//  Cleaner
//
//  Created by Hao on 10/16/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class GaugeView: UIView {
    var imageViewCenter: UIImageView!
    @IBOutlet weak var imageViewNeedSpeed: UIImageView!
    @IBInspectable var imageCenter: UIImage? {
        didSet{
            imageViewCenter.image = imageCenter
        }
    }
    @IBInspectable var sizeimageViewCenter: CGFloat = 27
    @IBInspectable var defaultLevel: CGFloat = 25.7
    @IBInspectable var maxLevel: CGFloat = 127
    @IBInspectable var minLevel: CGFloat = -127
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubviews()
    }
    func addSubviews() {
        imageViewCenter = UIImageView()
        addSubview(imageViewCenter)
    }
    fileprivate func rotateSpeedNeedle(speed: Float) {
        UIView.animate(withDuration: 0.5, animations: {
            self.imageViewNeedSpeed.transform = CGAffineTransform(rotationAngle: CGFloat(((.pi)/180) * speed))
        })
    }
    func updateSpeed(value: Float) {
        let convertedSpeed = Float(String(format: "%.1f", value))!
        var speedLevel:CGFloat
        // Set the angle limit for needle 25 to 150
        switch convertedSpeed {
        case 0.0:
            speedLevel = minLevel
        case 0.1:
            speedLevel = -(defaultLevel*4)
        case 0.2:
            speedLevel = -(defaultLevel*3)
        case 0.3:
            speedLevel = -(defaultLevel*2)
        case 0.4:
            speedLevel = -(defaultLevel)
        case 0.5:
            speedLevel = 0
        case 0.6:
            speedLevel = defaultLevel
        case 0.7:
            speedLevel = defaultLevel*2
        case 0.8:
            speedLevel = defaultLevel*3
        case 0.9:
            speedLevel = defaultLevel*4
        case 1.0:
            speedLevel = maxLevel
        default :
            speedLevel = 0
        }
        rotateSpeedNeedle(speed: Float(speedLevel))
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        imageViewCenter.frame = CGRect(x: self.frame.width/2 - sizeimageViewCenter/2, y: self.frame.height/2 - sizeimageViewCenter/2, width: sizeimageViewCenter, height: sizeimageViewCenter)
    }
    
}
