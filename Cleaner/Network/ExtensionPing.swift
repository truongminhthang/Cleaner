//
//  ExtensionPing.swift
//  Cleaner
//
//  Created by Hao on 10/15/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import Foundation


public typealias SimplePingClientCallback = (String?)->()
public class SimplePingClient: NSObject {
    fileprivate static let singletonPC = SimplePingClient()
    
    fileprivate var resultCallback: SimplePingClientCallback?
    fileprivate var pingClinet: SimplePing?
    fileprivate var dateReference: Date?
    
    public static func pingHostname(hostname: String, andResultCallback callback: SimplePingClientCallback?) {
        singletonPC.pingHostname(hostname: hostname, andResultCallback: callback)
    }
    
    public func pingHostname(hostname: String, andResultCallback callback:  SimplePingClientCallback?) {
        resultCallback = callback
        pingClinet = SimplePing(hostName: hostname)
        pingClinet?.delegate = self
        pingClinet?.start()
    }
}

extension SimplePingClient: SimplePingDelegate {
    
    public func simplePing(_ pinger: SimplePing, didSendPacket packet: Data, sequenceNumber: UInt16){
        dateReference = Date()
    }
    
    public func simplePing(_ pinger: SimplePing, didStartWithAddress address: Data) {
        pinger.send(with: nil)
    }
    
    public func simplePing(_ pinger: SimplePing, didFailWithError error: Error) {
        resultCallback?(nil)
    }
    
    public func simplePing(_ pinger: SimplePing, didReceiveUnexpectedPacket packet: Data) {
        pinger.stop()
        resultCallback?(nil)
    }
    
    public func simplePing(_ pinger: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16) {
        pinger.stop()
        guard let dateReference = dateReference else { return }
        
        //timeIntervalSinceDate returns seconds, so we convert to milis
        let latency = Date().timeIntervalSince(dateReference) * 1000
        resultCallback?(String(format: "%.f", latency))
    }
    
    public func simplePing(_ pinger: SimplePing, didFailToSendPacket packet: Data, sequenceNumber: UInt16, error: Error) {
        pinger.stop()
        resultCallback?(nil)
    }
    
}

