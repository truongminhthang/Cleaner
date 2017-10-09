//
//  WifiScanResultTableViewCell.swift
//  Cleaner
//
//  Created by Quốc Đạt on 07.10.17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit

class WifiScanResultTableViewCell: UITableViewCell {

    @IBOutlet weak var deviceImageView: UIImageView!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceIPLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
