//
//  DownloadTableViewCell.swift
//  Undercast
//
//  Created by coybit on 9/20/16.
//  Copyright © 2016 Coybit. All rights reserved.
//

import UIKit
import ZFRippleButton


class DownloadTableViewCell: UITableViewCell {

    @IBOutlet weak var progressState: UIProgressView!
    @IBOutlet weak var labelSubtitle: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var btnAction: ZFRippleButton!
    
    var downloadID: String?
    var downloading = true;
    
    var progress:Float {
        get {
            return progressState.progress;
        }
        set {
            self.progressState.progress = newValue;
            
            if( newValue == 1 ) {
                self.btnAction.isHidden = true;
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func actionButtonDidTouch(_ sender: UIButton) {
        
        if downloading {
            UCDownloader.sharedInstance.stop(downloadID!);
            sender.setTitle("Resume", for: UIControlState());
        }
        else  {
            UCDownloader.sharedInstance.restart(downloadID!);
            sender.setTitle("Pause", for: UIControlState());
        }

        downloading = !downloading;
    }
}
