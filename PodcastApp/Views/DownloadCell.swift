//
//  DownloadCell.swift
//  PodcastApp
//
//  Created by ScaRiLiX on 9/26/18.
//  Copyright © 2018 ScaRiLiX. All rights reserved.
//

import UIKit
import Kingfisher

class DownloadCell: UITableViewCell {
    
    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var episodePubDateLabel: UILabel!
    @IBOutlet weak var episodeNameLabel: UILabel!
    @IBOutlet weak var episodeDescriptionLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    
    var episode: Episode?
    {
        didSet
        {
            episodeImageView.kf.setImage(with: episode?.imageURL, placeholder: #imageLiteral(resourceName: "podcast icon"), options: [.transition(ImageTransition.fade(0.75))], progressBlock: nil, completionHandler: nil)
            episodePubDateLabel.text = episode?.pubDate?.dateString(ofStyle: .medium)
            episodeNameLabel.text = episode?.title
            episodeDescriptionLabel.text = episode?.description
        }
    }
}
