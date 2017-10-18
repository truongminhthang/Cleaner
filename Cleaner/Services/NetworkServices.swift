//
//  DownloadServices.swift
//  Cleaner
//
//  Created by Hao on 10/14/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import Foundation
import UIKit
import os.log
class NetworkServices: NSObject {
    let url = URL(string: "http://download.thinkbroadband.com/5MB.zip")
    
    static let shared : NetworkServices = NetworkServices()
    private override init() {
        super.init()
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        backgroundSession = URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
    }
    static var sessionNumber = 0
    var downloadTask: URLSessionDownloadTask?
    var uploadTask: URLSessionUploadTask?
    var backgroundSession: URLSession!
    
    private var downloadStartTime = Date()
    private var uploadStartTime = Date()
    var downloadSpeed : Float = 0.0
    var downloadSpeedDisplayedString : String = "_:__" {
        didSet {
            NotificationCenter.default.post(name: notificationKey2, object: nil)
        }
    }
    
    var uploadSpeed: Float = 0.0
    var uploadSpeedDisplayedString : String = "_:__" {
        didSet {
            NotificationCenter.default.post(name: notificationKey2, object: nil)
        }
    }
    
    func convertSpeedToDisplayedString(speed: Float) -> String {
        let speedConvert = String(format: "%.2f", speed)
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
    
    func startCheck() {
        uploadSpeed = 0.0
        downloadSpeed = 0.0
        downloadSpeedDisplayedString = "_:__"
        uploadSpeedDisplayedString = "_:__"
        downloadImageView()
    }
    
    
    private func downloadImageView() {
        downloadStartTime = Date()
        downloadTask = backgroundSession.downloadTask(with: url!)
        downloadTask?.resume()
    }
    
    private func uploadImage() {
        
        guard let imageData = UIImageJPEGRepresentation(UIImage(named: "AsterNovi-belgii-flower-1mb")!, 1) else {return }
        let uploadScriptUrl = URL(string:"http://swiftdeveloperblog.com/http-post-example-script/")
        var request = URLRequest(url: uploadScriptUrl!)
        request.httpMethod = "POST"
        request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        uploadTask = session.uploadTask(with: request, from: imageData)
        uploadStartTime = Date()
        uploadTask?.resume()
    }
}



extension NetworkServices: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        let downloadDuration = Float(Date().timeIntervalSince(downloadStartTime))
        self.downloadSpeed =  Float(totalBytesWritten / 1000000) / downloadDuration * 8
        self.downloadSpeedDisplayedString = self.convertSpeedToDisplayedString(speed: self.downloadSpeed)
    }
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        guard error == nil else {
            print(error!.localizedDescription)
            return
        }
        os_log("did Complete With no error", log: OSLog.default, type: .info)
        if task is URLSessionDownloadTask {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4 , execute: {[unowned self] in
                self.uploadImage()
            })
        }
        
    }
}

extension NetworkServices : URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let uploadDuration =  Float(Date().timeIntervalSince(uploadStartTime))
        DispatchQueue.main.async {[unowned self] in
            self.uploadSpeed = Float(totalBytesSent / 1000000)/uploadDuration * 8
            self.uploadSpeedDisplayedString = self.convertSpeedToDisplayedString(speed: self.uploadSpeed)
        }
    }
    
}


