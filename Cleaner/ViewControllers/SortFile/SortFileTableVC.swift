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
    
    override func viewDidLoad() {
        super.viewDidLoad()
       registerNotification()
    }
    
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NotificationName.didFinishFetchPHAsset, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.addSubview(headerView)
        let deviceServices = DeviceServices()
        let freeSize = deviceServices.diskFree.fileSizeString
        
        var myStringArr = freeSize.components(separatedBy: " ")
        let numbers: String = myStringArr[0]
        freeDiskLabel.text = numbers
        return view
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return PhotoServices.shared.displayedAssets.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cleanerAsset = PhotoServices.shared.displayedAssets[indexPath.row]
        let cellIdentifier = cleanerAsset.asset.duration == 0 ? "photoCell" : "videoCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TableViewCell
        
        switch cleanerAsset.thumbnailStatus {
        case .goodToGo:
            cell.photoImageView?.image = cleanerAsset.thumbnail
        case .fetching:
            cell.photoImageView?.image = UIImage(named: "photoDownloading")
        case .failed:
            cell.photoImageView?.image = UIImage(named: "photoDownloadError")
        }
        
        switch cleanerAsset.fileSizeStatus {
        case .goodToGo:
            cell.sizeLabel?.text = cleanerAsset.fileSize.fileSizeString
        case .fetching:
            cell.sizeLabel?.text = "Calculating"
        case .failed:
            cell.sizeLabel?.text = "Calculating failed"
        }
        return cell
    }
    
   

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        switch segue.identifier ?? "" {
        case "show Video Detail":
            guard let destination = segue.destination as? VideoViewController
                else { fatalError("unexpected view controller for segue") }
            if let selectedIndexPath = tableView.indexPathForSelectedRow  {
                destination.asset = PhotoServices.shared.displayedAssets[selectedIndexPath.row].asset
            }
        case "show photo details":
            guard let destination = segue.destination as? DetailImageVC
                else { fatalError("unexpected view controller for segue") }
            if let selectedIndexPath = tableView.indexPathForSelectedRow  {
                destination.asset = PhotoServices.shared.displayedAssets[selectedIndexPath.row].asset
            }
        default:
            return
        }


    }
    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        let asset = self.fetchResult!.object(at: indexPath.item)
//        if editingStyle == .delete {
//            PHPhotoLibrary.shared().performChanges({
//                PHAssetChangeRequest.deleteAssets([asset] as NSArray)
//            }, completionHandler: nil)
//        } else if editingStyle == .insert {
//
//        }
//    }
}

//// MARK: PHPhotoLibraryChangeObserver
//extension SortFileTableVC : PHPhotoLibraryChangeObserver {
//    func photoLibraryDidChange(_ changeInstance: PHChange) {
//
//        guard let changes = changeInstance.changeDetails(for: fetchResult!)
//            else { return }
//
//        // Change notifications may be made on a background queue. Re-dispatch to the
//        // main queue before acting on the change as we'll be updating the UI.
//        DispatchQueue.main.sync {
//            // Hang on to the new fetch result.
//            fetchResult = changes.fetchResultAfterChanges
//            if changes.hasIncrementalChanges {
//                // If we have incremental diffs, animate them in the collection view.
//                guard let tableView = self.tableView else { fatalError() }
//                if #available(iOS 11.0, *) {
//                    tableView.performBatchUpdates({
//                        if let removed = changes.removedIndexes, !removed.isEmpty {
//                            tableView.deleteRows(at: removed.map({ IndexPath(item: $0, section: 0) }), with: .automatic)
//                        }
//                        if let inserted = changes.insertedIndexes, !inserted.isEmpty {
//                            tableView.insertRows(at: inserted.map({ IndexPath(item: $0, section: 0) }), with: .automatic)
//                        }
//
//
//                    })
//                } else {
//                    if let removed = changes.removedIndexes, !removed.isEmpty {
//                        tableView.deleteRows(at: removed.map({ IndexPath(item: $0, section: 0) }), with: .automatic)
//                    }
//                    if let inserted = changes.insertedIndexes {
//                        tableView.insertRows(at: inserted.map({ IndexPath(item: $0, section: 0) }), with: .automatic)
//                    }
//                }
//            } else {
//                // Reload the collection view if incremental diffs are not available.
//                tableView!.reloadData()
//            }
//        }
//    }
//}

