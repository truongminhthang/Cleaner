//
//  TableViewController.swift
//  disk
//
//  Created by Quốc Đạt on 28.09.17.
//  Copyright © 2017 QuocDat. All rights reserved.
//

import UIKit
import Foundation
import Photos

class SortFileTableVC: UITableViewController {
    
    @IBOutlet weak var freeDiskLabel: UILabel!
    @IBOutlet var headerView: UIView!
    
    
    fileprivate var imageManager : PHCachingImageManager?
    fileprivate var thumbnailSize: CGSize = CGSize(width: 400, height: 400)
    fileprivate var previousPreheatRect = CGRect.zero
    
    var fetchResult : PHFetchResult<PHAsset>? {
        didSet {
            reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.requestAuthorization { [unowned self] (status) in
            switch status {
            case .authorized:
                PHPhotoLibrary.shared().register(self)
                let allPhotosOptions = PHFetchOptions()
                allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "duration", ascending: false), NSSortDescriptor(key: "pixelWidth", ascending: false), NSSortDescriptor(key: "pixelHeight", ascending: false)]
                self.fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
                self.imageManager = PHCachingImageManager()
            case .denied:
                fallthrough
            case .notDetermined:
                fallthrough
            case .restricted:
                showAlertToAccessAppFolder(title: "Warning", message: "We need permission to access Photo Library for this action")
            }
        }
    }
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self )
    }
    
    
    @objc func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        GoogleAdMob.sharedInstance.toogleBanner()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.addSubview(headerView)
        let deviceServices = DeviceServices()
        let freeSize = ByteCountFormatter.string(fromByteCount: Int64(deviceServices.diskFree), countStyle: .file)
        
        var myStringArr = freeSize.components(separatedBy: " ")
        let numbers: String = myStringArr[0]
        freeDiskLabel.text = numbers
        return view
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fetchResult?.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let asset = fetchResult!.object(at: indexPath.item)
        let cellIdentifier = asset.duration == 0 ? "photoCell" : "videoCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TableViewCell
        requestImage(for: cell, from: asset)
        // Request an image for the asset from the PHCachingImageManager.
        return cell
    }
    
    func requestImage(for cell:TableViewCell, from asset: PHAsset) {
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager?.requestImage(for: asset, targetSize: thumbnailSize , contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            
            if cell.representedAssetIdentifier == asset.localIdentifier && image != nil {
                cell.photoImageView.image = image
            }
        })
       
        if asset.duration ==  0 {
            imageManager?.requestImageData(for: asset, options: nil, resultHandler: { (data, string, orientation, dictionary) in
                guard data != nil else {return}
                cell.sizeLabel.text = ByteCountFormatter.string(fromByteCount: Int64(data!.count), countStyle: .file )
            })
        } else {
                    asset.getURL { (url) in
                        DispatchQueue.main.async {
                            cell.sizeLabel.text = ByteCountFormatter.string(fromByteCount: Int64(url?.fileSize ?? 0), countStyle: .file )
                        }
                    }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier ?? "" {
        case "show Video Detail":
            guard let destination = segue.destination as? VideoViewController
                else { fatalError("unexpected view controller for segue") }
            if let selectedIndexPath = tableView.indexPathForSelectedRow  {
                destination.asset = fetchResult!.object(at: selectedIndexPath.row)
            }
        case "show photo details":
            guard let destination = segue.destination as? DetailImageVC
                else { fatalError("unexpected view controller for segue") }
            if let selectedIndexPath = tableView.indexPathForSelectedRow  {
                destination.asset = fetchResult!.object(at: selectedIndexPath.row)
            }
        default:
            return
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let asset = self.fetchResult!.object(at: indexPath.item)
        if editingStyle == .delete {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets([asset] as NSArray)
            }, completionHandler: nil)
        } else if editingStyle == .insert {
            
        }
    }
}

// MARK: PHPhotoLibraryChangeObserver
extension SortFileTableVC : PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let changes = changeInstance.changeDetails(for: fetchResult!)
            else { return }
        
        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Hang on to the new fetch result.
            fetchResult = changes.fetchResultAfterChanges
            if changes.hasIncrementalChanges {
                // If we have incremental diffs, animate them in the collection view.
                guard let tableView = self.tableView else { fatalError() }
                if #available(iOS 11.0, *) {
                    tableView.performBatchUpdates({
                        if let removed = changes.removedIndexes, !removed.isEmpty {
                            tableView.deleteRows(at: removed.map({ IndexPath(item: $0, section: 0) }), with: .automatic)
                        }
                        if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                            tableView.insertRows(at: inserted.map({ IndexPath(item: $0, section: 0) }), with: .automatic)
                        }
                        
                        
                    })
                } else {
                    if let removed = changes.removedIndexes, !removed.isEmpty {
                        tableView.deleteRows(at: removed.map({ IndexPath(item: $0, section: 0) }), with: .automatic)
                    }
                    if let inserted = changes.insertedIndexes {
                        tableView.insertRows(at: inserted.map({ IndexPath(item: $0, section: 0) }), with: .automatic)
                    }
                }
            } else {
                // Reload the collection view if incremental diffs are not available.
                tableView!.reloadData()
            }
        }
    }
}

