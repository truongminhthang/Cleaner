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
    
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero
    
    var fetchResult = DataServices.shared.fetchResult
    var assetCollection = DataServices.shared.assetCollection
    var asset: PHAsset!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //    registerNotification()
        //     requestAuthorizationIfNeed()
        PHPhotoLibrary.shared().register(self )
        
        
        //   if fetchResult == nil {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        //   }
        
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
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    //
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 100
    }
    
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
        let asset = fetchResult?.object(at: indexPath.item)
        
        // Dequeue a GridViewCell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! TableViewCell
        
        
        // Request an image for the asset from the PHCachingImageManager.
        cell.representedAssetIdentifier = asset?.localIdentifier
        imageManager.requestImage(for: asset!, targetSize: CGSize(width: 400, height: 400), contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            
            if cell.representedAssetIdentifier == asset?.localIdentifier && image != nil {
                cell.photoImageView.image = image
            }
        })
        
        
        if asset?.duration == 0 {
            cell.representedAssetIdentifier = asset?.localIdentifier
            imageManager.requestImageData(for: asset!, options: nil, resultHandler: { (data, string, orientation, dictionary) in
                
                guard data != nil else {return}
                cell.sizeLabel.text = ByteCountFormatter.string(fromByteCount: Int64(data!.count), countStyle: .file )
                cell.typeLabel.text =  "Photo "
                cell.typeLabel.textColor = #colorLiteral(red: 0.3568627451, green: 0.7411764706, blue: 0.168627451, alpha: 1)
                cell.sizeLabel.textColor = #colorLiteral(red: 0.3568627451, green: 0.7411764706, blue: 0.168627451, alpha: 1)
                cell.typeImageView.image = #imageLiteral(resourceName: "Camera")
            })
        } else {
            let videoRequestOptions = PHVideoRequestOptions()
            videoRequestOptions.version = .original
            PHCachingImageManager.default().requestAVAsset(forVideo: asset!, options: videoRequestOptions, resultHandler: { (avasset, audioMix, diction) in
                if let url = (avasset as? AVURLAsset)?.url {
                    if let data = try? Data(contentsOf:url) {
                        DispatchQueue.main.sync {
                            cell.sizeLabel.text = ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file )
                            cell.typeLabel.text = " Video "
                            cell.typeLabel.textColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
                            cell.sizeLabel.textColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
                            cell.typeImageView.image = #imageLiteral(resourceName: "video")
                        }
                    
                    }
                }
            })

        
            
        }
        
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? DetailImageVC
            else { fatalError("unexpected view controller for segue") }
        guard let cell = sender as? UITableViewCell else { fatalError("unexpected sender") }
        
        if let indexPath = tableView?.indexPath(for: cell) {
            destination.asset = fetchResult?.object(at: indexPath.item)
            
        }
        destination.assetCollection = assetCollection
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let asset = self.fetchResult?.object(at: indexPath.item)
        let completion = { (success: Bool, error: Error?) -> Void in
            if success {
                DispatchQueue.main.sync {
                    tableView.reloadData()
                }
                
            } else {
                print("can't remove asset: \(String(describing: error))")
            }
        }
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([asset!] as NSArray)
        }, completionHandler: completion)
        
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
                        
                    })
                } else {
                    if let removed = changes.removedIndexes, !removed.isEmpty {
                        tableView.deleteRows(at: removed.map({ IndexPath(item: $0, section: 0) }), with: .automatic)
                    }
                }
            } else {
                // Reload the collection view if incremental diffs are not available.
                tableView!.reloadData()
            }
            
        }
    }
}

