//
//  PodcastTableViewCell.swift
//  Undercast
//
//  Created by coybit on 9/15/16.
//  Copyright © 2016 Coybit. All rights reserved.
//

import UIKit

class PodcastTableViewCell: UITableViewCell {

    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var labelDescription: UITextView!
    @IBOutlet weak var labelTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
