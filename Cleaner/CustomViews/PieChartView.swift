//
//  File1.swift
//  Cleaner
//
//  Created by Hao on 10/2/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit

class PieChartItem {
    var color: UIColor
    var value: Float
    
    init(value: Float = 0, color: UIColor) {
        self.color = color
        self.value = value
    }
}

@IBDesignable
class PieChartView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        if cornerRadius == -1 {
            self.layer.cornerRadius = self.bounds.width < self.bounds.height ? self.bounds.width * 0.5 : self.bounds.height * 0.5
        }
    }
    @IBInspectable var colorCenterCircle: UIColor = UIColor.clear
    @IBInspectable var centerRadius: CGFloat = 0
    var startDeg: Float = 0
    var endDeg: Float = 0
    var items: [PieChartItem] = []
    var sum: Float = 0
    
    // Add Item Circle
    func addItem(value: Float, color: UIColor) {
        let item = PieChartItem(value: value, color: color)
        items.append(item)
        sum += value
    }
    
    override func draw(_ rect: CGRect) {
        
        UIColor.clear.setFill()
        let outerPath = UIBezierPath(ovalIn: rect)
        outerPath.fill()
        
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let centerCircleRadius = (rect.width / 2) * centerRadius
        let radius: CGFloat = (self.bounds.size.width > self.bounds.size.height ? self.bounds.size.height : self.bounds.size.width)/2
        for item in items {
            drawItem(item: item, point: center, radius: radius)
        }
        
        drawCenterCircle(rect, radius: centerCircleRadius)
    }
    
    // Item Circle
    func drawItem(item: PieChartItem, point: CGPoint, radius: CGFloat) {
        let color = item.color
        color.setFill()
        let currentValue: Float = item.value
        let midPath = UIBezierPath()
        let theta: Float = (360.0 * (currentValue/sum))
        if theta > 0.0 {
            endDeg += theta
            
            if startDeg != endDeg {
                midPath.move(to: point)
                let startAngle: CGFloat = (CGFloat(startDeg)-90.0) * CGFloat(Double.pi) / 180.0
                let endAngle: CGFloat = (CGFloat(endDeg)-90.0) * CGFloat(Double.pi) / 180.0
                midPath.addArc(withCenter: point, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
                midPath.close()
                midPath.fill()
            }
        }
        startDeg = endDeg
    }
    
    //Center circle
    func drawCenterCircle(_ rect: CGRect, radius: CGFloat) {
        colorCenterCircle.setFill()
        let centerPath = UIBezierPath(ovalIn:
            rect.insetBy(dx: radius,
                         dy: radius))
        centerPath.fill()
    }
}


