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
class DetailImageVC: UIViewController, UIScrollViewDelegate {
    var assetCollection: PHAssetCollection!
    var asset: PHAsset!
    
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var creationDayLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.contentSize = detailImageView.frame.size
            scrollView.maximumZoomScale = 6.0
            scrollView.minimumZoomScale = 1.0
            
        }
    }

    fileprivate var playerLayer: AVPlayerLayer!
    fileprivate var playerLooper: AVPlayerLooper?
    fileprivate var isPlayingHint = false
    fileprivate let imageManager = PHCachingImageManager()
    
  
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PHPhotoLibrary.shared().register(self)
        displayImage()
      

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        GoogleAdMob.sharedInstance.toogleBanner()
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
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
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.detailImageView
    }
    

    
    func displayImage() {
        let options = PHImageRequestOptions()
        options.deliveryMode  = .highQualityFormat
        options.isNetworkAccessAllowed = true
      
        PHImageManager.default().requestImage(for: asset,
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
        
        imageManager.requestImageData(for: asset!, options: nil, resultHandler: { (data, string, orientation, dictionary) in
            guard data != nil else {
                return
            }
            self.sizeLabel.text = ByteCountFormatter.string(fromByteCount: Int64(data!.count), countStyle: .file )
            
            let date = self.asset.creationDate
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM , yyyy"
            let creationDate = dateFormatter.string(from: (date)!)
            
            self.creationDayLabel.text = creationDate
        })
        
    }
    
    
    
    
    
    @IBAction func deleteButton(_ sender: UIButton) {
        let completion = { (success: Bool, error: Error?) -> Void in
            if success {
                PHPhotoLibrary.shared().unregisterChangeObserver(self)
                DispatchQueue.main.sync {
                    _ = self.navigationController!.popViewController(animated: true)
                }
            } else {
                print("can't remove asset: \(String(describing: error))")
            }
        }
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([self.asset] as NSArray)
        }, completionHandler: completion)
        
    }
}


extension DetailImageVC: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.sync {
            guard let details = changeInstance.changeDetails(for: asset) else { return }
            guard let assetAfterChange = details.objectAfterChanges else {return}
            
            asset = assetAfterChange
            
            if details.assetContentChanged {
                
                playerLayer?.removeFromSuperlayer()
                playerLayer = nil
                playerLooper = nil
            }
        }
    }
    
    
}


