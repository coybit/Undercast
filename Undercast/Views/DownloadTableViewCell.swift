//
//  DownloadTableViewCell.swift
//  Undercast
//
//  Created by coybit on 9/20/16.
//  Copyright © 2016 Coybit. All rights reserved.
//

import UIKit

class DownloadTableViewCell: UITableViewCell {

    @IBOutlet weak var progressState: UIProgressView!
    @IBOutlet weak var labelSubtitle: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    
    var downloadID: String?
    var downloading = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func stopDidTouch(_ sender: UIButton) {
        
        if downloading {
            Downloader.sharedInstance.stop(downloadID!);
            sender.setTitle("Start", for: UIControlState());
        }
        else {
            Downloader.sharedInstance.restart(downloadID!);
            sender.setTitle("Cancel", for: UIControlState());
        }
        
        downloading = !downloading;
    }
}
