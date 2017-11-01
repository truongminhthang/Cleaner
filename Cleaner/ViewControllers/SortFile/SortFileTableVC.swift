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
    @IBOutlet weak var freeDiskUnitLabel: UILabel!
    @IBOutlet var headerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if PhotoServices.shared.isFetching {
            showActivity()
        }
        self.updateFreeDiskValue()
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
            self.updateFreeDiskValue()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateFreeDiskValue() {
        let freeSize = SystemServices.shared.diskSpaceUsage(inPercent: false).freeDiskSpace.fileSizeString
        let freeSizeStringArray = freeSize.components(separatedBy: " ")
        freeDiskLabel.text = freeSizeStringArray.first ?? ""
        freeDiskUnitLabel.text = freeSizeStringArray.last ?? ""
    }
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.addSubview(headerView)
        
        return view
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return PhotoServices.shared.displayedAssets.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cleanerAsset = PhotoServices.shared.displayedAssets[indexPath.row]
        let cellIdentifier = cleanerAsset.asset.duration == 0 ? "ImageCell" : "videoCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TableViewCell
        
        switch cleanerAsset.thumbnailStatus {
        case .goodToGo:
            cell.photoImageView?.image = cleanerAsset.thumbnail
        case .fetching, .failed:
            cell.photoImageView?.image = UIImage(named: "photoDownloadError")
            cell.typeAssetLabel?.text = "Error Asset"
            
            
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
                destination.cleanerAsset = PhotoServices.shared.displayedAssets[selectedIndexPath.row]
            }
        case "show photo details":
            guard let destination = segue.destination as? DetailImageVC
                else { fatalError("unexpected view controller for segue") }
            if let selectedIndexPath = tableView.indexPathForSelectedRow  {
                destination.cleanerAsset = PhotoServices.shared.displayedAssets[selectedIndexPath.row]
            }
        default:
            return
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let asset = PhotoServices.shared.displayedAssets[indexPath.row]
        if editingStyle == .delete {
            asset.remove(completionHandler: didFinishRemoveAsset)
        } else if editingStyle == .insert {
            
        }
    }
    
    func didFinishRemoveAsset(success: Bool, removedIndex: Int, error: Error?) {
        DispatchQueue.main.async {
            self.tableView.deleteRows(at: [IndexPath(item: removedIndex, section: 0)], with: .automatic)
        }
        
    }
    @IBAction func unwindToDeleteAsset(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? DetailVC{
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing meal.
                let asset = PhotoServices.shared.displayedAssets[selectedIndexPath.row]
                asset.remove(completionHandler: didFinishRemoveAsset)
            }
        }
    }
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



