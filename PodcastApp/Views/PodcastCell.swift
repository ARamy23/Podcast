//
//  PodcastCell.swift
//  PodcastApp
//
//  Created by ScaRiLiX on 9/23/18.
//  Copyright © 2018 ScaRiLiX. All rights reserved.
//

import UIKit
import Kingfisher

class PodcastCell: UITableViewCell {

    @IBOutlet weak var podcastImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var episodeCountLabel: UILabel!
    
    var model: Podcast?
    {
        didSet
        {
            podcastImageView.kf.setImage(with: model?.artworkUrl100?.url, placeholder: #imageLiteral(resourceName: "podcast icon"), options: [.transition(ImageTransition.fade(0.75))], progressBlock: nil, completionHandler: nil)
            trackNameLabel.text = model?.trackName ?? ""
            artistNameLabel.text = model?.artistName ?? ""
            episodeCountLabel.text = "\(model?.trackCount ?? 0) Episodes"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
