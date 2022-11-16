//
//  EpisodeCell.swift
//  PodcastsApp
//
//  Created by Donat Bajrami on 20.5.22.
//

import UIKit

class EpisodeCell: UITableViewCell {
    
    var episode: Episode! {
        didSet {
            episodeTitleLabel.text = episode.title
            
            let htmlDescription = String(htmlEncodedString: episode.description.description)
            descriptionLabel.text = htmlDescription
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            pubDateLabel.text = dateFormatter.string(from: episode.pubDate)
            
            guard let url = URL(string: episode.imageURL?.toSecureHTTPs() ?? "") else { return }
            episodeImageView.sd_setImage(with: url )
        }
    }
    
    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var pubDateLabel: UILabel!
    @IBOutlet weak var episodeTitleLabel: UILabel! {
        didSet {
            episodeTitleLabel.numberOfLines = 2
        }
    }
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.numberOfLines = 2
        }
    }
    @IBOutlet weak var progressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
