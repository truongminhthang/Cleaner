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
    var downloadSpeed : Float = 0.0 {
        didSet {
            NotificationCenter.default.post(name: NotificationName.updateDownloadSpeed, object: nil)
        }
    }
    
    var uploadSpeed: Float = 0.0 {
        didSet {
            NotificationCenter.default.post(name: NotificationName.updateUploadSpeed, object: nil)
        }
    }
   
    var isDownloading: Bool = false
    var isUploading: Bool = false
    func startDownload() {
        uploadSpeed = 0.0
        downloadSpeed = 0.0
        downloadImageView()
    }
    
    private func downloadImageView() {
        downloadStartTime = Date()
        downloadTask = backgroundSession.downloadTask(with: url!)
        downloadTask?.resume()
    }
    
    func startUpload() {
        
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
        os_log("did Finish Downloading To", log: OSLog.default, type: .info)
        NotificationCenter.default.post(name: NotificationName.didFinishTestDownload, object: nil)

    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async {[unowned self] in
            let downloadDuration = Float(Date().timeIntervalSince(self.downloadStartTime))
            self.downloadSpeed =  Float(totalBytesWritten) / downloadDuration * 8
        }
    }
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        guard error == nil else {
            print(error!.localizedDescription)
            return
        }
        if task is URLSessionUploadTask {
            NotificationCenter.default.post(name: NotificationName.didFinishTestUpload, object: nil)
        }
        
    }
}

extension NetworkServices : URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        DispatchQueue.main.async {[unowned self] in
            let uploadDuration =  Float(Date().timeIntervalSince(self.uploadStartTime))
            self.uploadSpeed = Float(totalBytesSent)/uploadDuration * 8
        }
    }
    
}


