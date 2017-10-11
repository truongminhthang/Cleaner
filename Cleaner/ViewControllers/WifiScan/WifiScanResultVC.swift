//
//  WifiScanResultVC.swift
//  Cleaner
//
//  Created by Quốc Đạt on 07.10.17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit
import Foundation

class WifiScanResultVC: UIViewController, UITableViewDataSource, UITableViewDelegate, NetworkScannerDelegate  {
   
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var networkScanner: NetworkScanner!
    private var myContext = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Init networkScanner. networkScanner is responsible for providing the business logic of the MainVC (MVVM)
        self.networkScanner = NetworkScanner(delegate:self)
        self.networkScanner.scan()
        //Add observers to monitor specific values on networkScanner. On change of those values MainVC UI will be updated
        self.addObserversForKVO()
        self.spinner.startAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addObserversForKVO ()->Void {
        
        self.networkScanner.addObserver(self, forKeyPath: "connectedDevices", options: .new, context:&myContext)
        
        self.networkScanner.addObserver(self, forKeyPath: "isScanRunning", options: .new, context:&myContext)
    }
    
    func removeObserversForKVO ()->Void {
        
        self.networkScanner.removeObserver(self, forKeyPath: "connectedDevices")
        
        self.networkScanner.removeObserver(self, forKeyPath: "isScanRunning")
    }
    
    
    
    @IBAction func reScan(_ sender: UIButton) {
        self.spinner.startAnimating()
        self.networkScanner.scan()
    }
    
    // MARK: NetworkScannerDelegate
    
    func networkScannerIPSearchFinished() {
        showAlert(vc: self, title: "Scan Finished", message: "Number of devices connected to the Local Area Network : \(self.networkScanner.connectedDevices.count)")
        resultLabel.text = "There are \(self.networkScanner.connectedDevices.count) connected to  \( self.networkScanner.ssidName ) "
        self.spinner.stopAnimating()
        self.spinner.hidesWhenStopped = true
    }
    
    func networkScannerIPSearchCancelled() {
        self.tableView.reloadData()
    }
    
    func networkScannerIPSearchFailed() {
        showAlert(vc: self, title: "Failed to scan", message: "Please make sure that you are connected to a WiFi before starting LAN Scan")
    }
    
    // -MARK: -Table View DataSource
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.networkScanner.connectedDevices!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath) as! WifiScanResultTableViewCell
        let device = self.networkScanner.connectedDevices[indexPath.row]
        cell.deviceIPLabel.text = device.ipAddress
        if indexPath.row == 0{
            cell.deviceNameLabel.text = "Me"
            cell.deviceImageView.image = #imageLiteral(resourceName: "user icon")
        } else {
            cell.deviceNameLabel.text = device.hostname
           cell.deviceImageView.image = #imageLiteral(resourceName: "guest icon")
        }
        return cell
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (context == &myContext) {
            
            switch keyPath! {
            case "connectedDevices":
                self.tableView.reloadData()
                
            case "isScanRunning":
//                let isScanRunning = change?[.newKey] as! BooleanLiteralType
            //   self.scanButton.image = isScanRunning ? #imageLiteral(resourceName: "stopBarButton") : #imageLiteral(resourceName: "refreshBarButton")
                break
            default:
                print("Not valid key for observing")
            }
            
        }
    }
    
    deinit {
        
        self.removeObserversForKVO()
    }
}
