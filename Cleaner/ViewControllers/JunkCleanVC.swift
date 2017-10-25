//
//  JunkCleanVC.swift
//  Cleaner
//
//  Created by Hao on 10/2/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit

class JunkCleanVC: UIViewController {

    @IBOutlet weak var freeDiskLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.freeDiskLabel.text  = ByteCountFormatter.string(fromByteCount: Int64(SystemServices.shared.diskSpaceUsage(inPercent: false).freeDiskSpace), countStyle: .binary)
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
    @IBAction func dismissToVC(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

