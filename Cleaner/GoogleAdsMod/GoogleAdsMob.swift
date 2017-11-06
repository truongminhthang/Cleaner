//
//  GoogleAdsMob.swift
//  Cleaner
//
//  Created by ChungTran on 10/18/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit
import GoogleMobileAds

//MARK: - Google Ads Unit ID
struct GoogleAdsUnitID {
    static var strBannerAdsID = "ca-app-pub-1435684048935421/1990778996"
    static var strInterstitialAdsID = "ca-app-pub-1435684048935421/7918441836"
}

//MARK: - Banner View Size
struct BannerViewSize {
    static var screenWidth = UIScreen.main.bounds.size.width
    static var screenHeight = UIScreen.main.bounds.size.height
    static var height = CGFloat((UIDevice.current.userInterfaceIdiom == .pad ? 90 : 50))
}
//MARK: - Create GoogleAdMob Class
class GoogleAdMob: NSObject, GADInterstitialDelegate {
    
    static let sharedInstance : GoogleAdMob = GoogleAdMob()
    
    private var isInitializeBannerView = false
    private var isInitializeInterstitial = false
    
    private var interstitialAds: GADInterstitial!
    private var bannerView: GADBannerView?
    
    var isTestMode = false
    //MARK: - Variable
    var isBannerDisplay = false {
        didSet {
            guard !isTestMode else {return}

            guard AppDelegate.shared.reachability.connection != .none else {return}

            if isBannerDisplay {
                self.bannerView?.isHidden = false
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                self.bannerView?.transform = CGAffineTransform(translationX: 0,
                                                               y: self.isBannerDisplay ? -BannerViewSize.height : BannerViewSize.height)
            }, completion: { (success) in
                if !self.isBannerDisplay {
                    self.bannerView?.isHidden = true
                }
            })
        }
    }
    
    override init() {
        super.init()
        createBannerView()
        self.createInterstitial()
    }
    
    @objc private func createBannerView() {
        guard !isTestMode else {return}
        guard AppDelegate.shared.reachability.connection != .none else {return}
        if UIApplication.shared.keyWindow?.rootViewController == nil {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(createBannerView), object: nil)
            self.perform(#selector(createBannerView), with: nil, afterDelay: 0.5)
        } else {
            bannerView = GADBannerView(frame: CGRect(
                x:0 ,
                y:BannerViewSize.screenHeight,
                width:BannerViewSize.screenWidth,
                height:BannerViewSize.height))
            self.bannerView?.adUnitID = GoogleAdsUnitID.strBannerAdsID
            self.bannerView?.rootViewController = UIApplication.shared.keyWindow?.rootViewController
            self.bannerView?.delegate = self
            self.bannerView?.backgroundColor = UIColor.clear
            self.bannerView?.load(GADRequest())
            
            UIApplication.shared.keyWindow?.addSubview(bannerView!)
        }
    }
    
    func toogleBanner() {
        isBannerDisplay = !isBannerDisplay
    }
    
    @objc func showBanner() {
        isBannerDisplay = true
    }
    
    private func createInterstitial() {
        guard !isTestMode else {return}
        interstitialAds = GADInterstitial(adUnitID: GoogleAdsUnitID.strInterstitialAdsID)
        interstitialAds.delegate = self
        interstitialAds.load(GADRequest())
    }
    
    func showInterstitial() {
        guard !isTestMode else {return}
        guard AppDelegate.shared.reachability.connection != .none else {return}
        if interstitialAds.isReady {
            interstitialAds.present(fromRootViewController: (UIApplication.shared.keyWindow?.rootViewController)!)
        } else {
            createInterstitial()
        }
    }
    //MARK: - GADInterstitial Delegate
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
       showInterstitial()
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        
    }
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        if !AppDelegate.shared.isDashboardDisplay {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(showBanner), object: nil)
            self.perform(#selector(showBanner), with: nil, afterDelay: 0.1)
        }
    }
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        
        self.isBannerDisplay = false
    }
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        
    }
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        
    }
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        
    }
}

// MARK: - GADBannerViewDelegate

extension GoogleAdMob: GADBannerViewDelegate {
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        
        print("adViewDidReceiveAd")
    }
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        
        print("adViewDidDismissScreen")
    }
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        
        print("adViewWillDismissScreen")
    }
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        
        print("adViewWillPresentScreen")
    }
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        
        print("adViewWillLeaveApplication")
    }
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        
        print("adView")
    }
}
