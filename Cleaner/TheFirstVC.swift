//
//  TheFirstVC.swift
//  Cleaner
//
//  Created by Hao on 10/2/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit
class TheFirstVC: UIViewController{
    
    @IBOutlet weak var speedButton: UIButton!
    @IBOutlet weak var wifiButton: UIButton!
    @IBOutlet weak var boostButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var junkCleanView: UIView!
    @IBOutlet weak var sortFilesView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tapGesture = UIGestureRecognizer(target: self, action: #selector(tapOnJunkClean(_:)))
        junkCleanView.addGestureRecognizer(tapGesture)
        pieChartView.addItem(value: 7, color: UIColor.yellow)
        pieChartView.addItem(value: 60, color: UIColor.clear)
        
  
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
