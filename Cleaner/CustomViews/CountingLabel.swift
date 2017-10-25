//
//  File.swift
//  DemoTestlabel
//
//  Created by Hao on 10/11/17.
//  Copyright © 2017 Hao. All rights reserved.
//


import Foundation
import UIKit

class CountingLabel: UILabel {
    let counterVelocity: Double = 3.0
    enum CounterAnimationType {
        case Linear //f(x) = x
        case EaseIn //f(x) = x^3
        case EaseOut // f(x) = (1-x)^3
    }
    enum CounterType {
        case Int
        case Float
    }
    var counterTyper: CounterType!
    var counterAnimationType: CounterAnimationType!
    var startNUmber: Double = 0.0
    var endNumber: Double = 0.0
    
    var progress: TimeInterval!
    var duration: TimeInterval!
    var lastUpdate: TimeInterval!
    var timer: Timer?
    var currentCounterValue:Double {
        if progress >= duration {
            return endNumber
        }
        
        let percentage = Double(progress / duration)
        let update = updateCounter(counterValue: percentage)
        
        return startNUmber + (update * (endNumber - startNUmber))
    }
    func count (fromValue : Double , to toValue: Double, withDuration duration: TimeInterval , andAnimationType animationType: CounterAnimationType , andCounterType counterType: CounterType ) {
        self.startNUmber = fromValue
        self.endNumber = toValue
        self.duration = duration
        self.counterTyper = counterType
        self.counterAnimationType = animationType
        self.progress = 0
        self.lastUpdate = Date.timeIntervalSinceReferenceDate
        
        if duration == 0 {
            updateText(value: toValue)
            return
        }
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(CountingLabel.updateValue), userInfo: nil, repeats: true)
    }
    @objc func updateValue() {
        let now = Date.timeIntervalSinceReferenceDate
        progress = progress + (now - lastUpdate)
        lastUpdate = now
        
        if progress >= duration {
            invalidateTimer()
            progress = duration
        }
        updateText(value: currentCounterValue)
    }
    
    func updateText(value: Double) {
        switch counterTyper! {
        case .Int:
            self.text = "\(value)"
        case .Float:
            self.text = String(format: "%.2f", value)
        default:
            break
        }
    }
    func updateCounter(counterValue: Double) -> Double {
        switch counterAnimationType! {
        case .Linear:
            return counterValue
        case .EaseIn:
            return pow(counterValue, counterVelocity)
        case .EaseOut:
            return 1.0 - pow(1.0 - counterValue, counterVelocity)
        default:
            break
        }
    }
    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
}
