//
//  wifiStoryboard.swift
//  Cleaner
//
//  Created by Quốc Đạt on 10/3/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit

class WifiVC: UIViewController  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isConnectionAvailable() {
            GoogleAdMob.sharedInstance.initializeBannerView()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GoogleAdMob.sharedInstance.hideBannerView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
