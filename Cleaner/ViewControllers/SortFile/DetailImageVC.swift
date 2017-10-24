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
    
    fileprivate lazy var formatIdentifier = Bundle.main.bundleIdentifier!
    fileprivate let formatVersion = "1.0"
    fileprivate lazy var ciContext = CIContext()
    lazy var pauseButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "pause")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor.white
        button.addTarget(self, action: #selector(pause), for: .touchUpInside)
       
        return button
    }()
    var isPlaying = false
    @objc func pause(){
        if isPlaying {
        playerLayer.player?.pause()
        pauseButton.setImage(UIImage(named: "play"), for: .normal)
        } else {
         playerLayer.player?.play()
        pauseButton.setImage(UIImage(named: "pause"), for: .normal)
        }
        
        isPlaying = !isPlaying
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PHPhotoLibrary.shared().register(self)
        
        updateContent()

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
    
    func updateContent() {
        if #available(iOS 11.0, *) {
            switch asset.playbackStyle {
            case .unsupported:
                let alertController = UIAlertController(title: NSLocalizedString("Unsupported Format", comment:""), message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                
            case .image:
                displayImage()
                
            case .video:
                playVideo()
            case .videoLooping:
                playVideo()
            case .imageAnimated:
                break
            case .livePhoto:
                break
            }
        } else {
            switch asset.mediaType {
            case .image:
                displayImage()
            case .video:
                playVideo()
                
            case .unknown:
                break
            case .audio:
                break
            }
        }
        
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
    
    func playVideo() {
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 1.0
        
        if playerLayer != nil {
            playerLayer.player!.play()
        } else {
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .automatic
           
            PHImageManager.default().requestPlayerItem(forVideo: asset, options: options, resultHandler: { playerItem, _ in
                DispatchQueue.main.sync {
                    guard self.playerLayer == nil && playerItem != nil else { return }
                    
                    // Create an AVPlayer and AVPlayerLayer with the AVPlayerItem.
                    let player: AVPlayer
                    if #available(iOS 11.0, *) {
                        if self.asset.playbackStyle == .videoLooping {
                            let queuePlayer = AVQueuePlayer(playerItem: playerItem)
                            self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem!)
                            player = queuePlayer
                        } else {
                            player = AVPlayer(playerItem: playerItem)
                        }
                        let playerLayer = AVPlayerLayer(player: player)
                        
                        // Configure the AVPlayerLayer and add it to the view.
                        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                        playerLayer.frame = self.detailImageView.frame
                        self.view.layer.addSublayer(playerLayer)
                        self.view.addSubview(self.pauseButton)
                        
                        self.pauseButton.centerXAnchor.constraint(equalTo: self.detailImageView.layoutMarginsGuide.centerXAnchor ).isActive = true
                        self.pauseButton.centerYAnchor.constraint(equalTo: self.detailImageView.layoutMarginsGuide.centerYAnchor ).isActive = true
                        self.pauseButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
                        self.pauseButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
                        player.play()
                        
                        // Refer to the player layer so we can remove it later.
                        self.playerLayer = playerLayer
                        self.isPlaying = true
                    } else {
                        if self.asset.mediaType == .video {
                            let queuePlayer = AVQueuePlayer(playerItem: playerItem)
                            self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem!)
                            player = queuePlayer
                        } else {
                            player = AVPlayer(playerItem: playerItem)
                        }
                        let playerLayer = AVPlayerLayer(player: player)
                        
                        // Configure the AVPlayerLayer and add it to the view.
                        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                        playerLayer.frame = self.detailImageView.frame
                        self.view.layer.addSublayer(playerLayer)
                        self.view.addSubview(self.pauseButton)
                        
                        self.pauseButton.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerXAnchor ).isActive = true
                        self.pauseButton.centerYAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerYAnchor ).isActive = true
                        self.pauseButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
                        self.pauseButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
                        player.play()
                        
                        // Refer to the player layer so we can remove it later.
                        self.playerLayer = playerLayer
                        self.isPlaying = true
                    }
                    
                    
                }
            })
            
        }
        if asset?.duration != 0 {
            
            let videoRequestOptions = PHVideoRequestOptions()
            videoRequestOptions.version = .original
            PHCachingImageManager.default().requestAVAsset(forVideo: asset!, options: videoRequestOptions, resultHandler: { (avasset, audioMix, diction) in
                if let url = (avasset as? AVURLAsset)?.url {
                    if let data = try? Data(contentsOf:url) {
                        DispatchQueue.main.sync {
                            self.sizeLabel.text = ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file )
                            let date = self.asset.creationDate
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "dd MMMM , yyyy"
                            let creationDate = dateFormatter.string(from: (date)!)
                            self.creationDayLabel.text = creationDate
                        }
                        
                    }
                }
            })
        }
        
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
                updateContent()
                
                playerLayer?.removeFromSuperlayer()
                playerLayer = nil
                playerLooper = nil
            }
        }
    }
    
    
}


