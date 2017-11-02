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
    @IBOutlet weak var addMoreFreeDiskLabel: UILabel!

    @IBOutlet var headerView: UIView!
    var timer : Timer?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        initPhotoServicesIfNeed()
        AppDelegate.shared.photoService?.shouldShowActivity = true
        freeSize = SystemServices.shared.diskSpaceUsage(inPercent: false).freeDiskSpace
        addMoreFreeDiskLabel.alpha = 0
        registerNotification()
    }
    
    func initPhotoServicesIfNeed() {
        guard AppDelegate.shared.photoService == nil else {return}
        AppDelegate.shared.photoService = PhotoServices()
    }  
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ActivityIndicator.shared.hideActivity()
        AppDelegate.shared.photoService?.shouldShowActivity = false

    }
    
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notification.Name.didFinishFetchPHAsset, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishSortedFile), name: Notification.Name.didFinishSortedFile, object: nil)
    }
    
    deinit {
        showAlert(title: "Info", message: "Need go to recently deleted photos Album to actually remove photos in your disk")
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    @objc func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func didFinishSortedFile() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.tableView.reloadData()
            self.freeSize = SystemServices.shared.diskSpaceUsage(inPercent: false).freeDiskSpace
        }
    }
    
    // MARK: - Handle display Free Disk and Saved Free Disk
    
    var freeSize : Double = 0 {
        didSet {
            let freeSizeString = freeSize.fileSizeString
            let freeSizeStringArray = freeSizeString.components(separatedBy: " ")
            freeDiskLabel.text = freeSizeStringArray.first ?? ""
            freeDiskUnitLabel.text = freeSizeStringArray.last ?? ""
        }
    }
    var addMoreFreeSize: Double = 0.0
    var displayAddMoreFreeSize: Double = 0.0 {
        didSet {
            addMoreFreeDiskLabel.text = "+" + displayAddMoreFreeSize.fileSizeString
        }
    }

    func startRunAddMoreValue() {
        if timer != nil { timer = nil }
        UIView.animate(withDuration: 0.05, animations: {
            self.addMoreFreeDiskLabel.alpha = 1
        }) {(success) in
            self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.runAddMoreValue), userInfo: nil, repeats: true)
        }
    }
    
    @objc func runAddMoreValue() {
        let step = 5278000.0
        guard displayAddMoreFreeSize < addMoreFreeSize - step else {           
            timer?.invalidate()
            timer = nil
            freeSize -= displayAddMoreFreeSize
            freeSize += addMoreFreeSize
            displayAddMoreFreeSize = addMoreFreeSize
            addMoreFreeSize = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIView.animate(withDuration: 0.2, animations: {
                    self.addMoreFreeDiskLabel.alpha = 0
                }) {(success) in
                    self.displayAddMoreFreeSize = 0
                }
            }
            return
        }
        DispatchQueue.main.async {
            self.displayAddMoreFreeSize += step
            self.freeSize += step
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return AppDelegate.shared.photoService!.displayedAssets.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cleanerAsset = AppDelegate.shared.photoService!.displayedAssets[indexPath.row]
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
                destination.cleanerAsset = AppDelegate.shared.photoService!.displayedAssets[selectedIndexPath.row]
            }
        case "show photo details":
            guard let destination = segue.destination as? DetailImageVC
                else { fatalError("unexpected view controller for segue") }
            if let selectedIndexPath = tableView.indexPathForSelectedRow  {
                destination.cleanerAsset = AppDelegate.shared.photoService!.displayedAssets[selectedIndexPath.row]
            }
        default:
            return
        }        
    }
    
    // MARK: - Handle add and remove asset
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let asset = AppDelegate.shared.photoService!.displayedAssets[indexPath.row]
        if editingStyle == .delete {
            asset.remove(completionHandler: didFinishRemoveAsset)
            addMoreFreeSize = Double(asset.fileSize)
        } else if editingStyle == .insert {
            
        }
    }
    
    func didFinishRemoveAsset(success: Bool, removedIndex: Int, error: Error?) {
        DispatchQueue.main.async {
            self.tableView.deleteRows(at: [IndexPath(item: removedIndex, section: 0)], with: .automatic)
            self.startRunAddMoreValue()
        }
    }
    
    @IBAction func unwindToDeleteAsset(sender: UIStoryboardSegue) {
        if sender.source is DetailVC{
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing meal.
                let asset = AppDelegate.shared.photoService!.displayedAssets[selectedIndexPath.row]
                asset.remove(completionHandler: didFinishRemoveAsset)
                addMoreFreeSize = Double(asset.fileSize)
            }
        }
    }
}
