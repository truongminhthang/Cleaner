//
//  NetworkSpeedVC.swift
//  Cleaner
//
//  Created by Hao on 10/15/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//


import UIKit

typealias Degree = Float
class NetworkSpeedVC: UIViewController ,SimplePingDelegate{
    let startTime = Date()
    
    @IBOutlet weak var speedButton: Button!
    @IBOutlet weak var indictorView: UIView!
    @IBOutlet weak var downloadAVGLabel: UILabel!
    @IBOutlet weak var uploadAVGLabel: UILabel!
    @IBOutlet weak var pingLabel: UILabel!
    let pingInterval: TimeInterval = 3
    let timeoutIntertval: TimeInterval = 4
    var networkService = NetworkServices.shared
    let fortyDegreeConstant = Float.pi / 180 * 45
    var currentIndicatorDegree : Float = 0 {
        didSet {
            self.rotateIndicator(with: currentIndicatorDegree)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        speedButton.isEnabled = true
        registerNotification()
        _ = isConnectionAvailable(vc: self)

        
    }
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateDownloadSpeed), name: NotificationName.updateDownloadSpeed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUploadSpeed), name: NotificationName.updateUploadSpeed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resetIndicator), name: NotificationName.didFinishTestUpload, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resetIndicatorAndTestUpload), name: NotificationName.didFinishTestDownload, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        networkService.stopAllTest()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func updateDownloadSpeed() {
        DispatchQueue.main.async { [unowned self] in
            self.downloadAVGLabel.text = self.convertSpeedToDisplayedString(speed: NetworkServices.shared.downloadSpeed)
            self.currentIndicatorDegree = self.convertFromSpeedToDegree(NetworkServices.shared.downloadSpeed)
        }
    }
    
    @objc func updateUploadSpeed() {
        DispatchQueue.main.async { [unowned self] in
            self.uploadAVGLabel.text = self.convertSpeedToDisplayedString(speed: NetworkServices.shared.uploadSpeed)
            self.currentIndicatorDegree = self.convertFromSpeedToDegree(NetworkServices.shared.uploadSpeed)
        }
    }
    
    @IBAction func clickAndStart(_ sender: UIButton) {
        if isConnectionAvailable(vc: self) {
        NetworkServices.shared.pingHostname(hostname: "192.168.1.1") { [unowned self] latency in
            DispatchQueue.main.async {
                self.pingLabel?.text = "\(latency ?? "--") ms"
                self.networkService.startDownload()
            }
        }
        speedButton.isEnabled = false
       } else {
            _ = isConnectionAvailable(vc: self)
        }
    }
    
    private func convertFromSpeedToDegree(_ speed: Float) -> Degree {
        switch speed {
        case 0 ..< 512_000:
            return speed * fortyDegreeConstant / 512_000
        case 512_000 ..< 2_000_000:
            let startPoint =  (fortyDegreeConstant)
            let rangeSpeed = Float(2_000_000 - 512_000)
            return (speed - 512_000) * fortyDegreeConstant / rangeSpeed + startPoint
        case 2_000_000 ..< 4_000_000:
            let rangeSpeed = Float(4_000_000 - 2_000_000)
            let startPoint =  (2 * fortyDegreeConstant)
            return (speed - 2_000_000) * fortyDegreeConstant / rangeSpeed + startPoint
            
        case 4_000_000 ..< 16_000_000:
            let rangeSpeed = Float(16_000_000 - 4_000_000)
            let startPoint =  (3 * fortyDegreeConstant)
            
            return (speed - 4_000_000) * fortyDegreeConstant / rangeSpeed + startPoint
            
        case 16_000_000 ..< 80_000_000:
            let rangeSpeed = Float(80_000_000 - 16_000_000)
            let startPoint =  (4 * fortyDegreeConstant)
            
            return (speed - 16_000_000) * fortyDegreeConstant / rangeSpeed + startPoint
            
        default:
            let startPoint =  (5 * fortyDegreeConstant)
            let rangeSpeed = Float(500_000_000 - 80_000_000)
            return (speed - 80_000_000) * fortyDegreeConstant / rangeSpeed + startPoint
            
        }
    }
    private func rotateIndicator(with degree: Float) {
        guard degree != 0 else {return}
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            self.indictorView.transform = CGAffineTransform(rotationAngle: CGFloat(degree))
        }, completion: nil)
    }
    @objc private func resetIndicatorAndTestUpload() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            self.indictorView.transform = CGAffineTransform(rotationAngle: CGFloat(0))
        }, completion: {success in
            NetworkServices.shared.startUpload()
            self.currentIndicatorDegree = 0
            self.speedButton.isEnabled = true
        })
        _ = isConnectionAvailable(vc: self)
    }
    
    @objc private func resetIndicator() {
        guard currentIndicatorDegree != 0 else {return}
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.indictorView.transform = CGAffineTransform(rotationAngle: CGFloat(0))
        },  completion: nil)
        speedButton.isEnabled = true
        _ = isConnectionAvailable(vc: self)
    }
    
    private func convertSpeedToDisplayedString(speed: Float) -> String {
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


