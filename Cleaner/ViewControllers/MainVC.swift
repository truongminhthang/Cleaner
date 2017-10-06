//
//  MainVC.swift
//  Cleaner
//
//  Created by Hao on 10/2/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit
class MainVC: UIViewController{
    
    @IBOutlet weak var speedButton: UIButton!
    @IBOutlet weak var wifiButton: UIButton!
    @IBOutlet weak var boostButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var junkCleanView: UIView!
    @IBOutlet weak var sortFilesView: UIView!
    
    @IBOutlet weak var freePercentLabel: UILabel!
    @IBOutlet weak var freeSpaceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tapGesture = UIGestureRecognizer(target: self, action: #selector(tapOnJunkClean(_:)))
        junkCleanView.addGestureRecognizer(tapGesture)
        let deviceServices = DeviceServices()
        pieChartView.addItem(value: 100 - Float(deviceServices.freePercent) , color: UIColor.red)
        pieChartView.addItem(value: Float(deviceServices.freePercent) , color: UIColor.clear)
        freePercentLabel.text = "\(Int(deviceServices.freePercent)) %"
        let freeSize = ByteCountFormatter.string(fromByteCount: Int64(deviceServices.diskFree), countStyle: .file)
        freeSpaceLabel.text = "\(freeSize)"
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //    func setColorView() {
    //        let gradient = CAGradientLayer()
    //        gradient.frame = grandView.bounds
    //        gradient.colors = [, ]
    //        grandView.layer.insertSublayer(gradient, at: 0)
    //    }
    
    @IBAction func bootButton(_ sender: UIButton) {
        
    }
    
    @IBAction func tapOnSortFiles(_ sender: UITapGestureRecognizer) {
        if let vc1 = self.storyboard?.instantiateViewController(withIdentifier: "vc1") as? SortFilesVC {
            AppDelegate.shared.window?.rootViewController!.present(vc1, animated: true, completion: nil)
        }
    }
    @IBAction func tapOnJunkClean(_ sender: UITapGestureRecognizer) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "vc") as? JunkCleanVC {
         AppDelegate.shared.window?.rootViewController!.present(vc, animated: true, completion: nil)
        }
        
    }
}
