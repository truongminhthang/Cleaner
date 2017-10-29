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
public typealias PingClientCallback = (String?)->()
class NetworkServices: NSObject {
    let url = URL(string: "http://www.nasa.gov/sites/default/files/saturn_collage.jpg")
    
    static let shared : NetworkServices = NetworkServices()
    // Init
    private override init() {
        super.init()
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        backgroundSession = URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
    }
    // Properties ping
    fileprivate var resultCallback: PingClientCallback?
    fileprivate var pingClinet: Ping?
    fileprivate var dateReference: Date?

    // Properties url session
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
    
    // Download
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
    
    // Upload
    func startUpload() {
        
        guard let imageData = UIImageJPEGRepresentation(UIImage(named: "pia03883-full")!, 1) else {return }
        let uploadScriptUrl = URL(string:"http://speedtest1.vtn.com.vn/speedtest/upload.php")
        var request = URLRequest(url: uploadScriptUrl!)
        request.httpMethod = "POST"
        request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        uploadTask = session.uploadTask(with: request, from: imageData)
        uploadStartTime = Date()
        uploadTask?.resume()
    }
    
    // Ping
    public static func pingHostname(hostname: String, andResultCallback callback: PingClientCallback?) {
        shared.pingHostname(hostname: hostname, andResultCallback: callback)
    }
    
    public func pingHostname(hostname: String, andResultCallback callback:  PingClientCallback?) {
        resultCallback = callback
        pingClinet = Ping(hostName: hostname)
        pingClinet?.delegate = self
        pingClinet?.start()
    }
}
// MARK: - URLSessionDownloadDelegate
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
            GoogleAdMob.sharedInstance.showInterstitial()
        }
        
    }
}
// MARK: - URLSessionTaskDelegate
extension NetworkServices : URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        DispatchQueue.main.async {[unowned self] in
            let uploadDuration =  Float(Date().timeIntervalSince(self.uploadStartTime))
            self.uploadSpeed = Float(totalBytesSent)/uploadDuration * 8
        }
    }
    
}
// MARK: - PingDelegate
extension NetworkServices: PingDelegate {
    public func ping(_ pinger: Ping, didSendPacket packet: Data, sequenceNumber: UInt16){
        dateReference = Date()
    }

    public func ping(_ pinger: Ping, didStartWithAddress address: Data) {
        pinger.send(with: nil)
    }

    public func ping(_ pinger: Ping, didFailWithError error: Error) {
        resultCallback?(nil)
    }

    public func ping(_ pinger: Ping, didReceiveUnexpectedPacket packet: Data) {
        pinger.stop()
        resultCallback?(nil)
    }

    public func ping(_ pinger: Ping, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16) {
        pinger.stop()
        guard let dateReference = dateReference else { return }

        //timeIntervalSinceDate returns seconds, so we convert to milis
        let latency = Date().timeIntervalSince(dateReference) * 1000
        resultCallback?(String(format: "%.f", latency))
    }

    public func ping(_ pinger: Ping, didFailToSendPacket packet: Data, sequenceNumber: UInt16, error: Error) {
        pinger.stop()
        resultCallback?(nil)
    }
}


