//
//  EpisodeTableViewCell.swift
//  Undercast
//
//  Created by coybit on 9/9/16.
//  Copyright © 2016 Coybit. All rights reserved.
//

import UIKit

class EpisodeTableViewCell: UITableViewCell {

    @IBOutlet weak var labelDownloaded: UILabel!
    @IBOutlet weak var labelDifference: UILabel!
    @IBOutlet weak var labelPodcastName: UILabel!
    @IBOutlet weak var labelEpisodeName: UILabel!
    @IBOutlet weak var labelDuration: UILabel!
    @IBOutlet weak var labelPublishDate: UILabel!
    @IBOutlet weak var imageCover: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.labelDifference.layer.cornerRadius = 4;
        self.labelDownloaded.layer.cornerRadius = 4;
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func playDidTouch(_ sender: AnyObject) {
    }
}
