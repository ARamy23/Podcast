//
//  EpisodeCell.swift
//  PodcastApp
//
//  Created by ScaRiLiX on 9/24/18.
//  Copyright © 2018 ScaRiLiX. All rights reserved.
//

import UIKit
import FeedKit

class EpisodeCell: UITableViewCell {

    
    @IBOutlet weak var mainBackgroundView: UIView!
    @IBOutlet weak var shadowLayer: UIView!
    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var episodeNameLabel: UILabel!
    @IBOutlet weak var episodeDescriptionLabel: UILabel!
    
    //MARK:- Helping Variables
    var podcastImage: UIImage?
    
    
    var episode: Episode?
    {
        didSet
        {
            dateLabel.text = episode?.pubDate?.dateString(ofStyle: DateFormatter.Style.medium)
            episodeNameLabel.text = episode?.title
            episodeDescriptionLabel.text = episode?.description
            
            episodeImageView.kf.setImage(with: episode?.imageURL, placeholder: podcastImage ?? #imageLiteral(resourceName: "podcast icon"), options: [.transition(.fade(0.5))], progressBlock: nil, completionHandler: nil)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews()
    {
        super.layoutSubviews()
        contentView.frame.inset(by: UIEdgeInsets(horizontal: 30, vertical: 30))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
