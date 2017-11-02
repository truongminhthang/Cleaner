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

protocol NetworkServicesToVCProtocol: class {
    func networkServices(_ networkServices: NetworkServices, updateDownloadSpeed downloadSpeed: Double)
    func networkServices(_ networkServices: NetworkServices, updateUploadSpeed uploadSpeed: Double)
    func networkServices(_ networkServices: NetworkServices, updatelatency latency: Double?)
    func didFinishDownload()
    func didFinishUpload()
}

class NetworkServices: NSObject {
    let url = URL(string: "http://speedtest1.vtn.com.vn/speedtest/random4000x4000.jpg")
    static let shared : NetworkServices = NetworkServices()
    
    weak var delegate: NetworkServicesToVCProtocol?
    
    // Properties ping
    fileprivate var pingClinet = Ping(hostName: "speedtest1.vtn.com.vn")
    fileprivate var dateReference: Date?

    // Properties url session
    static var sessionNumber = 0
    var downloadTask: URLSessionDownloadTask?
    var uploadTask: URLSessionUploadTask?
    var backgroundSession: URLSession!
    
    private var downloadStartTime = Date()
    private var uploadStartTime = Date()
    var downloadSpeed : Double = 0.0 {
        didSet {
            delegate?.networkServices(self, updateDownloadSpeed: downloadSpeed)
        }
    }
    
    var uploadSpeed: Double = 0.0 {
        didSet {
            delegate?.networkServices(self, updateUploadSpeed: uploadSpeed)
        }
    }
    
    var latency: Double? = 0.0 {
        didSet {
            delegate?.networkServices(self, updatelatency: latency)
        }
    }
    
    // Init
    private override init() {
        super.init()
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        backgroundSessionConfiguration.timeoutIntervalForResource = TimeInterval(10)
        backgroundSession = URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        
        pingClinet.delegate = self
    }
    
    
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
        configuration.timeoutIntervalForResource = TimeInterval(10)
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        uploadTask = session.uploadTask(with: request, from: imageData)
        uploadStartTime = Date()
        uploadTask?.resume()
    }
    
    // Ping
    
    func ping() {
        pingClinet.start()
    }
    
    func stopPing(pinger: Ping, latency:Double? = nil) {
        pinger.stop()
        self.latency = latency
        startDownload()
    }
    
    public func stopAllTest() {
        pingClinet.stop()
        downloadTask?.cancel()
        uploadTask?.cancel()
    }
}
// MARK: - URLSessionDownloadDelegate
extension NetworkServices: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async {[unowned self] in
            let downloadDuration = Double(Date().timeIntervalSince(self.downloadStartTime))
            self.downloadSpeed =  Double(totalBytesWritten) / downloadDuration * 8
        }
    }
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {

        delegate?.didFinishDownload()
        downloadTask.cancel()

    }
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        if task is URLSessionDownloadTask {
            delegate?.didFinishDownload()
        } else if task is URLSessionUploadTask {
            delegate?.didFinishUpload()
        }
        task.cancel()

    }
}
// MARK: - URLSessionTaskDelegate
extension NetworkServices : URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        DispatchQueue.main.async {[unowned self] in
            let uploadDuration =  Double(Date().timeIntervalSince(self.uploadStartTime))
            self.uploadSpeed = Double(totalBytesSent)/uploadDuration * 8
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
        stopPing(pinger: pinger)
        
    }
    public func ping(_ pinger: Ping, didReceiveUnexpectedPacket packet: Data) {
        stopPing(pinger: pinger)
    }
    public func ping(_ pinger: Ping, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16) {
        guard let dateReference = dateReference else { return }
        //timeIntervalSinceDate returns seconds, so we convert to milis
        let latency = Date().timeIntervalSince(dateReference) * 1000
        stopPing(pinger: pinger, latency: latency)
    }
    public func ping(_ pinger: Ping, didFailToSendPacket packet: Data, sequenceNumber: UInt16, error: Error) {
        stopPing(pinger: pinger)

    }
}


