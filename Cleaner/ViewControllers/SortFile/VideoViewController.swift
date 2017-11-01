//
//  VideoViewController.swift
//  Cleaner
//
//  Created by Quốc Đạt on 10/26/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit
import Photos

class VideoViewController: UIViewController {
    var assetCollection: PHAssetCollection!
    var cleanerAsset: CleanerAsset!
    var player: AVPlayer!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopCorverButton: UIButton!
    fileprivate var playerLayer: AVPlayerLayer?
    fileprivate var playerLooper: AVPlayerLooper?
    var isPlaying = false {
        didSet {
            playButton.isHidden = isPlaying
            stopCorverButton.isHidden = !isPlaying
            if isPlaying {
                playerLayer?.player?.play()
            } else {
                playerLayer?.player?.pause()
            }

        }
    }

    @IBOutlet weak var videoContainer: UIView!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var creationDayLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getVideoInfo()
        initPlayerLayer()
        registerNotification()
        if cleanerAsset.thumbnailStatus == .fetching {
            cleanerAsset.fetchImage(completeBlock: initPlayerLayer)
        }
    }
    
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(resetPlayer), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func resetPlayer() {
        isPlaying = false
        player?.resetVideo()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        GoogleAdMob.sharedInstance.toogleBanner()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
       resetPlayer()
    }
    
    func getVideoInfo() {
        self.sizeLabel.text = cleanerAsset.fileSize.fileSizeString
        self.creationDayLabel.text = cleanerAsset.dateCreatedString
        
    }
    
    func initPlayerLayer() {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .automatic
        
        PHImageManager.default().requestPlayerItem(forVideo: cleanerAsset.asset, options: options, resultHandler: { [unowned self] (playerItem, _) in
            DispatchQueue.main.sync {
                guard self.playerLayer == nil && playerItem != nil else { return }
                // Create an AVPlayer and AVPlayerLayer with the AVPlayerItem.
                if #available(iOS 11.0, *) {
                    if self.cleanerAsset.asset.playbackStyle == .videoLooping {
                        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
                        self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem!)
                        self.player = queuePlayer
                    } else {
                        self.player = AVPlayer(playerItem: playerItem)
                    }
                } else {
                    if self.cleanerAsset.asset.mediaType == .video {
                        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
                        self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem!)
                        self.player = queuePlayer
                    } else {
                        self.player = AVPlayer(playerItem: playerItem)
                    }
                }
                let playerLayer = AVPlayerLayer(player: self.player)
                // Configure the AVPlayerLayer and add it to the view.
                playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                playerLayer.frame = self.videoContainer.bounds
                self.videoContainer.layer.addSublayer(playerLayer)
                self.playerLayer =  playerLayer
                
            }
        })
    }
    @IBAction func pause(sender: UIButton!) {
        isPlaying = !isPlaying
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        let completion = { (success: Bool, error: Error?) -> Void in
            if success {
                DispatchQueue.main.sync {
                    _ = self.navigationController!.popViewController(animated: true)
                }
            } else {
                print("can't remove asset: \(String(describing: error))")
            }
        }
        cleanerAsset.remove(completionHandler: completion)
    }
}

extension AVPlayer {
    func resetVideo() {
        seek(to: CMTimeMakeWithSeconds(Float64(0), 1))
    }
}

