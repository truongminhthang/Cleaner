//
//  ContactVC.swift
//  Cleaner
//
//  Created by Apple on 10/30/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit
import MessageUI

class ContactVC: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var navigationItem1: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func sendEmail(sender: AnyObject) {
        let mailComposerVC = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposerVC, animated: true, completion: nil)
        } else {
            self.sendMailFailed()
        }
    }
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["yourEmail@gmail.com"])
        mailComposerVC.setSubject("App Feedback")
        mailComposerVC.setMessageBody("FuckYou Bitches", isHTML: false)
        
        return mailComposerVC
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled :
            print("Canceled sent email")
        case .sent :
            print("sending Email")
            
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func sendMailFailed() {
        let sendMailError =  UIAlertView(title: "Could Not send Email", message: "Your device could not send Email. Please check Email configuration and try again", delegate: self, cancelButtonTitle: "OK")
        sendMailError.show()
    }

    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
        }
}
