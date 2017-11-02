//
//  NetworkSpeedVC.swift
//  Cleaner
//
//  Created by Hao on 10/15/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//


import UIKit
import os.log

typealias Degree = Double

class NetworkSpeedVC: UIViewController ,SimplePingDelegate, NetworkServicesToVCProtocol{
    let startTime = Date()
    
    @IBOutlet weak var speedButton: Button!
    @IBOutlet weak var indictorView: UIView!
    @IBOutlet weak var downloadAVGLabel: UILabel!
    @IBOutlet weak var uploadAVGLabel: UILabel!
    @IBOutlet weak var pingLabel: UILabel!
    let pingInterval: TimeInterval = 3
    let timeoutIntertval: TimeInterval = 4
    var networkService = NetworkServices.shared
    let fortyDegreeConstant = Double.pi / 180 * 45
    var indicatorFlag = true
    var currentIndicatorDegree : Double = 0 {
        didSet {
            if currentIndicatorDegree >= Double.pi, indicatorFlag {
                self.rotateIndicator(with: currentIndicatorDegree / 2, completeHander:  {
                    self.rotateIndicator(with: self.currentIndicatorDegree)
                })
                indicatorFlag = false
            } else {
                
                self.rotateIndicator(with: currentIndicatorDegree)
            }

        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        speedButton.isEnabled = true
        NetworkServices.shared.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppDelegate.shared.reachabilityChanged()
    }
    
    deinit {
        networkService.stopAllTest()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func networkServices(_ networkServices: NetworkServices, updateDownloadSpeed downloadSpeed: Double) {
        DispatchQueue.main.async { [unowned self] in
            self.downloadAVGLabel.text = self.convertSpeedToDisplayedString(speed: downloadSpeed)
            self.currentIndicatorDegree = self.convertFromSpeedToDegree(downloadSpeed)
        }
    }
    func networkServices(_ networkServices: NetworkServices, updateUploadSpeed uploadSpeed: Double) {
        DispatchQueue.main.async { [unowned self] in
            self.uploadAVGLabel.text = self.convertSpeedToDisplayedString(speed: uploadSpeed)
            self.currentIndicatorDegree = self.convertFromSpeedToDegree(uploadSpeed)
        }
    }
    func networkServices(_ networkServices: NetworkServices, updatelatency latency: Double?) {
        DispatchQueue.main.async { [unowned self] in
            if latency != nil {
                self.pingLabel?.text = String(format: "%.f ms", latency!)
            } else {
                self.pingLabel?.text = "error"
            }
        }
    }
    func didFinishDownload() {
        print("didFinishDownload")
        DispatchQueue.main.async {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.reset(completeHandler: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.indicatorFlag = true
                        NetworkServices.shared.startUpload()
                        
                    }
                })
            }
            
        }
    }
    func didFinishUpload() {
        print("didFinishUpload")
        DispatchQueue.main.async {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.reset(completeHandler: {
                    self.indicatorFlag = true
                    self.speedButton.isEnabled = true

                })
            }
        }
    }
    
    func reset(completeHandler: (() -> Void)? = nil ) {
        self.rotateIndicator(with: currentIndicatorDegree / 2, completeHander: {
            self.rotateIndicator(with: Double(0), completeHander: {
                self.currentIndicatorDegree = 0
                completeHandler?()
            }, duration: 0.7)
        },duration: 0.7)
    }
    
    @IBAction func clickAndStart(_ sender: UIButton) {
        guard AppDelegate.shared.reachability.connection != .none else {
            showAlert(title: "Please connect to Internet first", message: "", completeHandler: {[weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            return
        }
        NetworkServices.shared.ping()
        speedButton.isEnabled = false
    }
    
    private func convertFromSpeedToDegree(_ speed: Double) -> Degree {
        switch speed {
        case 0 ..< 512_000:
            return speed * fortyDegreeConstant / 512_000
        case 512_000 ..< 2_000_000:
            let startPoint =  (fortyDegreeConstant)
            let rangeSpeed = Double(2_000_000 - 512_000)
            return (speed - 512_000) * fortyDegreeConstant / rangeSpeed + startPoint
        case 2_000_000 ..< 4_000_000:
            let rangeSpeed = Double(4_000_000 - 2_000_000)
            let startPoint =  (2 * fortyDegreeConstant)
            return (speed - 2_000_000) * fortyDegreeConstant / rangeSpeed + startPoint
            
        case 4_000_000 ..< 16_000_000:
            let rangeSpeed = Double(16_000_000 - 4_000_000)
            let startPoint =  (3 * fortyDegreeConstant)
            
            return (speed - 4_000_000) * fortyDegreeConstant / rangeSpeed + startPoint
            
        case 16_000_000 ..< 80_000_000:
            let rangeSpeed = Double(80_000_000 - 16_000_000)
            let startPoint =  (4 * fortyDegreeConstant)
            
            return (speed - 16_000_000) * fortyDegreeConstant / rangeSpeed + startPoint
            
        default:
            let startPoint =  (5 * fortyDegreeConstant)
            let rangeSpeed = Double(500_000_000 - 80_000_000)
            return (speed - 80_000_000) * fortyDegreeConstant / rangeSpeed + startPoint
        }
    }
    private func rotateIndicator(with degree: Double, completeHander: (()-> Void)? = nil, duration: Double = 0.1) {
        UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: {
            self.indictorView.transform = CGAffineTransform(rotationAngle: CGFloat(degree))
        }, completion: { success in
            completeHander?()}
        )
    }
    
    
    private func convertSpeedToDisplayedString(speed: Double) -> String {
        let speedConvert = String(format: "%.2f", speed / 1_000_000)
        let speedConvertString = Measurement(value: Double(speedConvert)!, unit: UnitDataRate.megabitPerSecond)
        let defaulte = Measurement(value: 1, unit: UnitDataRate.megabitPerSecond)
        let max = Measurement(value: 1000, unit: UnitDataRate.megabitPerSecond)
        if speedConvertString < defaulte {
            return "\(speedConvertString.converted(to: UnitDataRate.kilobitPerSecond))"
        } else if speedConvertString > max {
            return "\(speedConvertString.converted(to: UnitDataRate.gigabitPerSecond))"
        } else {
            return "\(speedConvertString.converted(to: UnitDataRate.megabitPerSecond))"
        }
    }
}


