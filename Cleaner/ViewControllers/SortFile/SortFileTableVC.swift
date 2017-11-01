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
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    var timer : Timer?
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
            addMoreFreeDiskLabel.text = "+" + displayAddMoreFreeSize.fileBinarySizeString
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        freeSize = SystemServices.shared.diskSpaceUsage(inPercent: false).freeDiskSpace
        addMoreFreeDiskLabel.alpha = 0
        registerNotification()
    }
    
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NotificationName.didFinishFetchPHAsset, object: nil)
        
    }
    
    deinit {
        showAlert(title: "Info", message: "Need go to recently deleted photos Album to actually remove photos in your disk")
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    @objc func reloadData() {
        DispatchQueue.main.async {
            self.indicatorView.stopAnimating()
            self.tableView.reloadData()
            self.updateFreeDiskValue()
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
            freeSize -= displayAddMoreFreeSize
            freeSize += addMoreFreeSize
            displayAddMoreFreeSize = addMoreFreeSize
            timer?.invalidate()
            timer = nil
            self.addMoreFreeSize = 0
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
    
    func updateFreeDiskValue() {
        
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
                let asset = PhotoServices.shared.displayedAssets[selectedIndexPath.row]
                asset.remove(completionHandler: didFinishRemoveAsset)
                addMoreFreeSize = Double(asset.fileSize)
            }
        }
    }
}
