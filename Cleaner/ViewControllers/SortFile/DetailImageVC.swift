//
//  DetailImage.swift
//  Cleaner
//
//  Created by Quốc Đạt on 11.10.17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit
import Photos
import AVKit

class DetailVC: UIViewController {
    var cleanerAsset: CleanerAsset!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var creationDayLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        getInfo()
    }
    
    func getInfo() {
        self.sizeLabel.text = cleanerAsset.fileSize.fileSizeString
        self.creationDayLabel.text = cleanerAsset.dateCreatedString
        
    }
}
class DetailImageVC: DetailVC, UIScrollViewDelegate {

    
    @IBOutlet weak var detailImageView: UIImageView!

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.contentSize = detailImageView.frame.size
            scrollView.maximumZoomScale = 6.0
            scrollView.minimumZoomScale = 1.0
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        displayImage()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        GoogleAdMob.sharedInstance.toogleBanner()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.detailImageView
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var targetSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: detailImageView.bounds.width * scale,
                      height: detailImageView.bounds.height * scale )
    }
    func displayImage() {
        let options = PHImageRequestOptions()
        options.deliveryMode  = .highQualityFormat
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestImage(for: cleanerAsset.asset,
                                              targetSize: targetSize,
                                              contentMode: .aspectFit,
                                              options: options,
                                              resultHandler: { image, _ in
                                                
                                                // If successful, show the image view and display the image.
                                                guard let image = image else { return }
                                                
                                                // Now that we have the image, show it.
                                                self.detailImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
                                                self.detailImageView.contentMode = UIViewContentMode.scaleAspectFit
                                                self.detailImageView.image = image
        })
        
    }
}

