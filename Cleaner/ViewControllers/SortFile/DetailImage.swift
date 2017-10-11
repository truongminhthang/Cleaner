//
//  DetailImage.swift
//  Cleaner
//
//  Created by Quốc Đạt on 11.10.17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit

class DetailImage: UIViewController {

    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var creationDayLabel: UILabel!
    @IBOutlet weak var hightForImageView: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        let index = DataServices.shared.indexPathInSelectedRow
        
        let imageSize = ByteCountFormatter.string(fromByteCount: Int64(DataServices.shared.imageArray[index].size), countStyle: .file)
        sizeLabel.text = "\(imageSize)"
     //   creationDayLabel.textColor =  DataServices.shared.imageArray[index]
        detailImageView.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth, .flexibleHeight,.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
        detailImageView.contentMode = UIViewContentMode.scaleAspectFit
       // hightForImageView.constant = view
            detailImageView.image = DataServices.shared.imageArray[index].image
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

    @IBAction func deleteButton(_ sender: UIButton) {
        
    }
}
