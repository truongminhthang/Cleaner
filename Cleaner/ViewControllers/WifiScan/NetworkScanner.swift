//
//  NetworkScanner.swift
//  Cleaner
//
//  Created by Quốc Đạt on 07.10.17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit
import Foundation

protocol NetworkScannerDelegate {
    func networkScannerIPSearchFinished()
    func networkScannerIPSearchCancelled()
    func networkScannerIPSearchFailed()
}

class NetworkScanner: NSObject, MMLANScannerDelegate {
    
    @objc dynamic var connectedDevices : [MMDevice]!
    @objc dynamic var progressValue : Float = 0.0
    @objc dynamic var isScanRunning : BooleanLiteralType = false
    
    var lanScanner : MMLANScanner!
    var delegate : NetworkScannerDelegate?
    
    //MARK: - Custom init method
    //Initialization with delegate
    init(delegate:NetworkScannerDelegate?){
        
        super.init()
        
        self.delegate = delegate!
        
        self.connectedDevices = [MMDevice]()
        
        self.isScanRunning = false
        
        self.lanScanner = MMLANScanner(delegate:self)
    }
    
    //MARK: - Button Actions
    //This method is responsible for handling the tap button action on MainVC. In case the scan is running and the button is tapped it will stop the scan
    func scan()-> Void {
        self.isScanRunning ? stop() : start()
    }
    
    func start() ->Void{
        
        if (self.isScanRunning) {
            
            self.stop()
            self.connectedDevices.removeAll()
        }
        else {
            self.connectedDevices.removeAll()
            self.isScanRunning = true
            self.lanScanner.start()
        }
    }
    
    func stop() ->Void{
        
        self.lanScanner.stop()
        self.isScanRunning = false
    }
    
    //MARK: - SSID Info
    //Getting the SSID string using LANProperties
    
    var ssidName : String {
        return LANProperties.fetchSSIDInfo()
    }
    
    // MARK: - MMLANScanner Delegates
    //The delegate methods of MMLANScanner
    func lanScanDidFindNewDevice(_ device: MMDevice!) {
        //Adding the found device in the array
        if(!self.connectedDevices .contains(device)) {
            self.connectedDevices?.append(device)
        }
        
        let ipSortDescriptor = NSSortDescriptor(key: "ipAddress", ascending: true)
        self.connectedDevices = (self.connectedDevices as NSArray).sortedArray(using: [ipSortDescriptor]) as! Array
    }
    
    func lanScanDidFailedToScan() {
        
        self.isScanRunning = false
        self.delegate?.networkScannerIPSearchFailed()
    }
    
    func lanScanDidFinishScanning(with status: MMLanScannerStatus) {
        
        self.isScanRunning = false
        
        //Checks the status of finished. Then call the appropriate method
        switch status {
        case MMLanScannerStatusFinished:
            self.delegate?.networkScannerIPSearchFinished()
        case MMLanScannerStatusFinished:
            return
        case MMLanScannerStatusCancelled:
            self.delegate?.networkScannerIPSearchCancelled()
        default:
            return
        }
       
    }
    
    func lanScanProgressPinged(_ pingedHosts: Float, from overallHosts: Int) {
        
        //Updating the progress value. MainVC will be notified by KVO
        self.progressValue = pingedHosts / Float(overallHosts)
    }
    
}

