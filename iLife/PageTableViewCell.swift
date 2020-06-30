//
//  PageTableViewCell.swift
//  iLife
//
//  Created by Mirosław Witkowski.
//  Copyright © 2020 Mirosław Witkowski. All rights reserved.
//

import UIKit

class PageTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var imageImageView: UIImageView!
    @IBOutlet weak var smallLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    //MARK: Override functions

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
