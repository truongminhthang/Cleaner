//
//  TableViewCell.swift
//  disk
//
//  Created by Quốc Đạt on 28.09.17.
//  Copyright © 2017 QuocDat. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var typeAssetLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        sizeLabel.text = ""
        typeAssetLabel.text = ""
        photoImageView.image = nil 
    }
    
}
class ImageCell: TableViewCell {
    override func prepareForReuse() {
        sizeLabel.text = ""
        typeAssetLabel.text = "Photo"
        photoImageView.image = nil
    }
}

class VideoCell: TableViewCell {
    override func prepareForReuse() {
        sizeLabel.text = ""
        typeAssetLabel.text = "Video"
        photoImageView.image = nil
    }
}
