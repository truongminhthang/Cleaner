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
    @IBOutlet weak var downloadAVGLabel: UILabel!
    @IBOutlet weak var uploadAVGLabel: UILabel!
    @IBOutlet weak var pingLabel: UILabel!
    let pingInterval: TimeInterval = 3
    let timeoutIntertval: TimeInterval = 4
    override func viewDidLoad() {
        super.viewDidLoad()
         NetworkServices.shared.taskDownload()
        registerNotification()
        
    }
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateLabel), name: notificationKey2, object: nil)
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func updateLabel() {
     self.downloadAVGLabel.text =   NetworkServices.shared.timeDownload
       self.uploadAVGLabel.text = NetworkServices.shared.timeUpload
       
    }
    @IBAction func clickAndStart(_ sender: UIButton) {
        SimplePingClient.pingHostname(hostname: "192.168.1.1") { latency in
            self.pingLabel.text = "\(latency ?? "--") ms"
            print("Your latency is \(latency ?? "unknown")")
        }
       NetworkServices.shared.downloadImageView()
    }
}


