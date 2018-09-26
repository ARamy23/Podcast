//
//  FavoritesCell.swift
//  PodcastApp
//
//  Created by ScaRiLiX on 9/25/18.
//  Copyright © 2018 ScaRiLiX. All rights reserved.
//

import UIKit
import Kingfisher

class FavoritesCell: UICollectionViewCell {

    
    @IBOutlet weak var podcastImageView: UIImageView!
    @IBOutlet weak var podcastTitleLabel: UILabel!
    @IBOutlet weak var podcastAuthorLabel: UILabel!
    
    var podcast: Podcast?
    {
        didSet
        {
            
            podcastImageView.kf.setImage(with: podcast?.artworkUrl100?.url, placeholder: #imageLiteral(resourceName: "podcast icon"), options: [.transition(ImageTransition.fade(0.75))], progressBlock: nil, completionHandler: nil)
            podcastTitleLabel.text = podcast?.trackName
            podcastAuthorLabel.text = podcast?.artistName
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
