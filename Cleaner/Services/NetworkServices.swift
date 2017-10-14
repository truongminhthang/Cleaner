//
//  DownloadServices.swift
//  Cleaner
//
//  Created by Hao on 10/14/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import Foundation
import UIKit
class NetworkServices {
    static let shared: NetworkServices  = NetworkServices()
    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: URLSession!
    private var _imageViewI: UIImage?
    var imageViewI: UIImage {
        get{
            if _imageViewI == nil {
                downloadImageView()
            }
            return _imageViewI ?? UIImage()
        }
        set
        {
            _imageViewI = newValue
        }
    }
    
    
    func downloadImageView() {
        let url = URL(string: "https://upload.wikimedia.org/wikipedia/commons/1/16/AsterNovi-belgii-flower-1mb.jpg")
        downloadTask = backgroundSession.downloadTask(with: url!)
        downloadTask.resume()
        
        let session = URLSession.shared
        let task = session.dataTask(with: url!) {  data, response, error in
            guard
                let data = data , error == nil,
                let imageView = UIImage(data: data)
                else { return }
            DispatchQueue.main.async {
                self._imageViewI = imageView
                NotificationCenter.default.post(name: Notification.Name.init("imageView"), object: nil)
            }
        }
        task.resume()
    }
    func uploadImage() {
        
        let imageData = UIImageJPEGRepresentation(UIImage(named: "AsterNovi-belgii-flower-1mb")!, 1)
        if(imageData == nil ) { return }
        let uploadScriptUrl = URL(string:"http://www.swiftdeveloperblog.com/http-post-example-script/")
        var request = URLRequest(url: uploadScriptUrl!)
        request.httpMethod = "POST"
       request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self as? URLSessionDelegate, delegateQueue: OperationQueue.main)
        let task = session.uploadTask(with: request, from: imageData ) { data, response, error in
                        guard error == nil && data != nil else {
                            return
                        }
                    }
                    task.resume()
        NotificationCenter.default.post(name: Notification.Name.init("uploadData") , object: nil)
    }
}



extension NetworkSpeedVC: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        let timeUseDownload =  CGFloat(Date().timeIntervalSince(startTime))
        print(timeUseDownload)
        let speedDownLoad = (CGFloat(totalBytesWritten) / 1000000)/timeUseDownload * 8
        let speedConvertStr = String(format: "%.2f", speedDownLoad)
       
        let speedConvert = Measurement(value: Double(speedConvertStr)!, unit: UnitDataRate.megabitPerSecond)
         print(speedConvert)
        let defaulte = Measurement(value: 1, unit: UnitDataRate.megabitPerSecond)
        if defaulte > speedConvert {
            self.downloadAVGLabel.text = "\(speedConvert.converted(to: UnitDataRate.kilobitPerSecond))"
        } else {
            self.downloadAVGLabel.text = "\(speedConvert.converted(to: UnitDataRate.megabitPerSecond))"
        }
      
        
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
extension NetworkSpeedVC : URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        NetworkServices.shared.uploadImage()
        let timeUseUploat = CGFloat(Date().timeIntervalSince(startTime))
        let upLoadSpeed = (CGFloat(totalBytesSent) / 1000000 ) / timeUseUploat * 8
        let speedConvertStrU = String(format: "%.2f", upLoadSpeed)
        
        let speedConvertU = Measurement(value: Double(speedConvertStrU)!, unit: UnitDataRate.megabitPerSecond)
        print(speedConvertU)
        let defaulte = Measurement(value: 1, unit: UnitDataRate.megabitPerSecond)
        if defaulte > speedConvertU {
            self.uploadAVGLabel.text = "\(speedConvertU.converted(to: UnitDataRate.kilobitPerSecond))"
        } else {
            self.uploadAVGLabel.text = "\(speedConvertU.converted(to: UnitDataRate.megabitPerSecond))"
        }
    }
    func uploadImage() {
        
        let imageData = UIImageJPEGRepresentation(UIImage(named: "AsterNovi-belgii-flower-1mb")!, 1)
        if(imageData == nil ) { return }
        let uploadScriptUrl = URL(string:"http://www.swiftdeveloperblog.com/http-post-example-script/")
        var request = URLRequest(url: uploadScriptUrl!)
        request.httpMethod = "POST"
        request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self , delegateQueue: OperationQueue.main)
        let task = session.uploadTask(with: request, from: imageData ) { data, response, error in
            guard error == nil && data != nil else {
                return
            }
        }
        task.resume()
    }
}
