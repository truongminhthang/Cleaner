//
//  VideoViewController.swift
//  Cleaner
//
//  Created by Quốc Đạt on 10/26/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit
import Photos

class VideoViewController: DetailVC {
    @IBOutlet weak var videoContainer: UIView!
    var player: AVPlayer!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopCorverButton: UIButton!
    fileprivate var playerLayer: AVPlayerLayer?
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
    override func viewDidLoad() {
        super.viewDidLoad()
        initPlayerLayer()
        registerNotification()
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
    
    func initPlayerLayer() {
        PHImageManager.default().requestPlayerItem(forVideo: cleanerAsset.asset, options: nil, resultHandler: { [unowned self] (playerItem, _) in
            DispatchQueue.main.sync {
                guard self.playerLayer == nil && playerItem != nil else { return }
                // Create an AVPlayer and AVPlayerLayer with the AVPlayerItem.
                if #available(iOS 11.0, *) {
                    if self.cleanerAsset.asset.playbackStyle == .videoLooping {
                        self.player = AVQueuePlayer(playerItem: playerItem)
                    } else {
                        self.player = AVPlayer(playerItem: playerItem)
                    }
                }  else {
                    if self.cleanerAsset.asset.mediaType == .video {
                        self.player = AVQueuePlayer(playerItem: playerItem)
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
}

extension AVPlayer {
    func resetVideo() {
        seek(to: CMTimeMakeWithSeconds(Float64(0), 1))
    }
}

