//
//  TableViewController.swift
//  disk
//
//  Created by Quốc Đạt on 28.09.17.
//  Copyright © 2017 QuocDat. All rights reserved.
//

import UIKit
import Foundation
class SortFileTableVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      registerNotification()
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
  
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 100
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       // guard  let free = DeviceService().diskFree else { fatalError()}
      let free = DeviceService().diskFree
        let freeSize = ByteCountFormatter.string(fromByteCount: Int64(free), countStyle: .file)
        
        return "\(freeSize)  available"
    }
    
  
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return DataService.shared.imageArray.count
    }
    
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! TableViewCell
        cell.photoImageView.image = DataService.shared.imageArray[indexPath.row]
        let sizeByte = (DataService.shared.imageSize[indexPath.row])
        let imageSize = ByteCountFormatter.string(fromByteCount: Int64(sizeByte), countStyle: .file)
        cell.sizeLabel.text = "\(imageSize)"
        cell.typeLabel.text = " Photo"
     return cell
     }
    
    
 
}
