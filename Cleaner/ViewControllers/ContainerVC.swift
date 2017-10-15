//
//  ContainerVC.swift
//  Cleaner
//
//  Created by Hao on 10/4/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit

class ContainerVC: UIViewController {
    
    @IBOutlet weak var sideMenu: UIView!
    @IBOutlet weak var leftSideMenuConstraint: NSLayoutConstraint!
    var isSideMenuOpen: Bool = true {
        didSet{ 
            self.leftSideMenuConstraint.constant = self.isSideMenuOpen ? -30 : -self.sideMenu.bounds.width
            
            UIView.animate(withDuration: 0.35, animations: {
                self.view.layoutIfNeeded() })
            { (isSuccess) in
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        registerNotification()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isSideMenuOpen = false
    }
    
  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(backButton(_:)), name: notificationKey, object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func backButton(_ sender: UIButton) {
        isSideMenuOpen = !isSideMenuOpen
    }
}
