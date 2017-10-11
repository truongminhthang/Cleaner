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
        DataServices.shared.updateImageArray()
      
    }
    
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name.init("imageArrayUpdate"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func reloadData() {
        tableView.reloadData()
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
        return DataServices.shared.imageArray.count
    }
    
    
    
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! TableViewCell
        cell.photoImageView.image = DataServices.shared.imageArray[indexPath.row].image
        let sizeByte = (DataServices.shared.imageArray[indexPath.row].size)
        let imageSize = ByteCountFormatter.string(fromByteCount: Int64(sizeByte), countStyle: .file)
        cell.sizeLabel.text = "\(imageSize)"
        
        if DataServices.shared.imageArray[indexPath.row].type == "video" {
            cell.typeLabel.text = " Video "
            cell.typeLabel.textColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
            cell.sizeLabel.textColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
            cell.typeImageView.image = #imageLiteral(resourceName: "video")
        } else {
            
             cell.typeLabel.text =  "Photo "
            cell.typeLabel.textColor = #colorLiteral(red: 0.3568627451, green: 0.7411764706, blue: 0.168627451, alpha: 1)
            cell.sizeLabel.textColor = #colorLiteral(red: 0.3568627451, green: 0.7411764706, blue: 0.168627451, alpha: 1)
            cell.typeImageView.image = #imageLiteral(resourceName: "Image")
        }
     return cell
     }
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DataServices.shared.indexPathInSelectedRow = indexPath.row
    }
  

    
}
