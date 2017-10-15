//
//  DownloadServices.swift
//  Cleaner
//
//  Created by Hao on 10/14/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import Foundation
import UIKit
class NetworkServices: NSObject {
    static let shared: NetworkServices = NetworkServices()
    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: URLSession!
   
    var startTime1 = Date()
    var startTime2 = Date()
    
 
    private var _timeDownload: String?
    var timeDownload:String {
        get {
            if _timeDownload == nil {
            }
            return _timeDownload ?? ""
        }
        set{
            _timeDownload = newValue
        }
    }
    private var _timeUpload: String?
    var timeUpload:String {
        get {
            if _timeUpload == nil {
            }
            return _timeUpload ?? ""
        }
        set{
            _timeUpload = newValue
        }
    }
    
    func taskDownload() {
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        
    }

    func downloadImageView() {
        let url = URL(string: "http://www.nasa.gov/sites/default/files/wave_earth_mosaic_3.jpg")
        downloadTask = backgroundSession.downloadTask(with: url!)
        downloadTask.resume()
        
        let session = URLSession.shared
        let startTimeDownload = Date()
        startTime1 = startTimeDownload
        let task = session.dataTask(with: url!) {  data, response, error in
            guard
                let _ = data , error == nil
                else { return }
            
            defer {
                self.delayWithSeconds(4) {
                    self.uploadImage()
                }
            }
        }
        task.resume()
    }
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds , execute: {
          completion()
        })
    }
    func uploadImage() {
        
        let imageData = UIImageJPEGRepresentation(UIImage(named: "AsterNovi-belgii-flower-1mb")!, 1)
        if(imageData == nil ) { return }
        let uploadScriptUrl = URL(string:"https://api.imgur.com/3/image")
        var request = URLRequest(url: uploadScriptUrl!)
        request.httpMethod = "POST"
        request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
       
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
            let startTimeUpload = Date()
            startTime2 = startTimeUpload
        let task = session.uploadTask(with: request, from: imageData ) { data, response, error in
            guard error == nil && data != nil else {
                return
            }
        
           
        }
        task.resume()
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
        
        let endTimeUpload = CGFloat(Date().timeIntervalSince(startTime1))
        print("timedownload \(endTimeUpload)")
        let speedDownLoad = (CGFloat(totalBytesWritten) / 1000000)/endTimeUpload * 8
        print(totalBytesWritten)
        let speedConvertStr = String(format: "%.2f", speedDownLoad)
        
        let speedConvert = Measurement(value: Double(speedConvertStr)!, unit: UnitDataRate.megabitPerSecond)
        print(speedConvert)
        let defaulte = Measurement(value: 1, unit: UnitDataRate.megabitPerSecond)
        if defaulte > speedConvert {
            self._timeDownload = "\(speedConvert.converted(to: UnitDataRate.kilobitPerSecond))"
        } else {
            self._timeDownload = "\(speedConvert.converted(to: UnitDataRate.megabitPerSecond))"
        }
        NotificationCenter.default.post(name: notificationKey2, object: nil)
    }
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        NetworkServices.shared.downloadTask = nil
        if (error != nil) {
            print(error!.localizedDescription)
        }else{
            print("The task finished transferring data successfully")
        }
    }
}
extension NetworkServices : URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        let endTime =  CGFloat(Date().timeIntervalSince(startTime2))
        let upLoadSpeed = (CGFloat(totalBytesSent) / 1000000 ) / endTime * 8
        let speedConvertStrU = String(format: "%.2f", upLoadSpeed)
        
        let speedConvertU = Measurement(value: Double(speedConvertStrU)!, unit: UnitDataRate.megabitPerSecond)
        print("timeupload \(endTime)")
        let defaulte = Measurement(value: 1, unit: UnitDataRate.megabitPerSecond)
        if defaulte > speedConvertU {
            self._timeUpload = "\(speedConvertU.converted(to: UnitDataRate.kilobitPerSecond))"
        } else {
            self._timeUpload = "\(speedConvertU.converted(to: UnitDataRate.megabitPerSecond))"
        }
        NotificationCenter.default.post(name: notificationKey2, object: nil)
    }
    
}


