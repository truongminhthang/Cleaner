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
class GoogleAdMob:NSObject, GADInterstitialDelegate, GADBannerViewDelegate {
    
    //MARK: - Shared Instance
    static let sharedInstance : GoogleAdMob = {
        let instance = GoogleAdMob()
        return instance
    }()
    
    //MARK: - Variable
    private var isBannerViewDisplay = false
    
    private var isInitializeBannerView = false
    private var isInitializeInterstitial = false
    
    private var interstitialAds: GADInterstitial!
    private var bannerView: GADBannerView!
    
    
    //MARK: - Create Banner View
    func initializeBannerView() {
        self.isInitializeBannerView = true
        self.createBannerView()
    }
    func initTopBannerView() {
        self.isInitializeBannerView = true
        if UIApplication.shared.keyWindow?.rootViewController == nil {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(createBannerView), object: nil)
            self.perform(#selector(createBannerView), with: nil, afterDelay: 0.5)
        } else {
            
            isBannerViewDisplay = true
            bannerView = GADBannerView(frame: CGRect(
                x:0 ,
                y: 102  ,
                width: 425   ,
                height: 50))
            self.bannerView.adUnitID = GoogleAdsUnitID.strBannerAdsID
            self.bannerView.rootViewController = UIApplication.shared.keyWindow?.rootViewController
            self.bannerView.delegate = self
            self.bannerView.backgroundColor = UIColor.clear
            self.bannerView.load(GADRequest())
            UIApplication.shared.keyWindow?.addSubview(bannerView)
        }

    }
    @objc private func createBannerView() {
        
        print("GoogleAdMob : create")
        if UIApplication.shared.keyWindow?.rootViewController == nil {
            
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(createBannerView), object: nil)
            self.perform(#selector(createBannerView), with: nil, afterDelay: 0.5)
        } else {
            
            isBannerViewDisplay = true
            bannerView = GADBannerView(frame: CGRect(
                x:0 ,
                y:BannerViewSize.screenHeight - BannerViewSize.height ,
                width:BannerViewSize.screenWidth ,
                height:BannerViewSize.height))
            self.bannerView.adUnitID = GoogleAdsUnitID.strBannerAdsID
            self.bannerView.rootViewController = UIApplication.shared.keyWindow?.rootViewController
            self.bannerView.delegate = self
            self.bannerView.backgroundColor = UIColor.clear
            self.bannerView.load(GADRequest())
            UIApplication.shared.keyWindow?.addSubview(bannerView)
        }
    }
    //MARK: - Hide - Show Banner View
    func showBannerView() {
        
        print("showBannerView")
        isBannerViewDisplay = true
        if isInitializeBannerView == false {
            print("First initialize Banner View")
        } else {
            
            print("isBannerViewCreate : true")
            self.bannerView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.bannerView.frame = CGRect(x:0 ,y:BannerViewSize.screenHeight - BannerViewSize.height ,width:BannerViewSize.screenWidth ,height:BannerViewSize.height)
            })
        }
    }
    func hideBannerView() {
        print("hideBannerView")
        isBannerViewDisplay = false
        if self.bannerView != nil {
            UIView.animate(withDuration: 0.3, animations: {
                self.bannerView.frame = CGRect(x:0 ,y:BannerViewSize.screenHeight ,width:BannerViewSize.screenWidth ,height:BannerViewSize.height)
            })
        }
    }
    @objc private func showBanner() {
        print("showBanner")
        if self.bannerView != nil && isBannerViewDisplay == true {
            self.bannerView.isHidden = false
        }
    }
    private func hideBanner() {
        print("hideBanner")
        if self.bannerView != nil {
            self.bannerView.isHidden = true
        }
    }
    //MARK: - GADBannerView Delegate
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
    //MARK: - Create Interstitial Ads
    func initializeInterstitial() {
        self.isInitializeInterstitial = true
        self.createInterstitial()
    }
    private func createInterstitial() {
        interstitialAds = GADInterstitial(adUnitID: GoogleAdsUnitID.strInterstitialAdsID)
        interstitialAds.delegate = self
        interstitialAds.load(GADRequest())
    }
    //MARK: - Show Interstitial Ads
    func showInterstitial() {
        
        if isInitializeInterstitial == false {
            
            print("First initialize Interstitial")
        } else {
            
            if interstitialAds.isReady {
                interstitialAds.present(fromRootViewController: (UIApplication.shared.keyWindow?.rootViewController)!)
                
            } else {
                print("Interstitial not ready")
                self.createInterstitial()
            }
        }
    }
    //MARK: - GADInterstitial Delegate
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        
        print("interstitialDidReceiveAd")
    }
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        
        print("interstitialDidDismissScreen")
        self.createInterstitial()
    }
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        
        print("interstitialWillDismissScreen")
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(showBanner), object: nil)
        self.perform(#selector(showBanner), with: nil, afterDelay: 0.1)
    }
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        
        print("interstitialWillPresentScreen")
        self.hideBanner()
    }
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        
        print("interstitialWillLeaveApplication")
    }
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        
        print("interstitialDidFail")
    }
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        
        print("interstitial")
    }
}
