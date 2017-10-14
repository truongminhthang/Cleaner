//
//  NetworkSpeedVC.swift
//  Cleaner
//
//  Created by Luyen on 10/4/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit

class NetworkSpeedVC: UIViewController {
    let startTime = Date()
    @IBOutlet weak var downloadAVGLabel: UILabel!
    @IBOutlet weak var uploadAVGLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        NetworkServices.shared.backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        
        // Do any additional setup after loading the view.
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

    @IBAction func clickAndStart(_ sender: UIButton) {
        let queue = DispatchQueue.init(label: "LB")
        queue.sync {
             NetworkServices.shared.downloadImageView()
        }
              self.uploadImage()
    }
}
