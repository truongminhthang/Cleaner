//
//  NetworkSpeedVC.swift
//  Cleaner
//
//  Created by Hao on 10/15/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//


import UIKit


class NetworkSpeedVC: UIViewController ,SimplePingDelegate{
    let startTime = Date()
    
    @IBOutlet weak var speedButton: Button!
    @IBOutlet weak var biggestCircle: GaugeView!
    @IBOutlet weak var downloadAVGLabel: UILabel!
    @IBOutlet weak var uploadAVGLabel: UILabel!
    @IBOutlet weak var pingLabel: UILabel!
    let pingInterval: TimeInterval = 3
    let timeoutIntertval: TimeInterval = 4
    var networkService = NetworkServices.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        speedButton.isEnabled = true
        registerNotification()        
    }

    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateLabel), name: notificationKey2, object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
        networkService.downloadTask?.cancel()
        networkService.uploadTask?.cancel()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func updateLabel() {
        DispatchQueue.main.async { [unowned self] in
            self.downloadAVGLabel.text =  self.networkService.downloadSpeedDisplayedString
            self.uploadAVGLabel.text = self.networkService.uploadSpeedDisplayedString
        }
        
    }
    @IBAction func clickAndStart(_ sender: UIButton) {
        
        SimplePingClient.pingHostname(hostname: "192.168.1.1") { [unowned self] latency in
            self.pingLabel.text = "\(latency ?? "--") ms"
        }
        networkService.startCheck()
        speedButton.isEnabled = false

    }
    
}


