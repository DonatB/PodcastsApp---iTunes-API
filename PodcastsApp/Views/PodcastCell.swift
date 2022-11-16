//
//  PodcastCell.swift
//  PodcastsApp
//
//  Created by Donat Bajrami on 19.5.22.
//

import UIKit
import SDWebImage

class PodcastCell: UITableViewCell {
    
    @IBOutlet weak var podcastImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var episodeCountLabel: UILabel!
    
    var podcast: Podcast! {
        didSet {
            trackNameLabel.text = podcast.trackName
            artistNameLabel.text = podcast.artistName
            episodeCountLabel.text = "\(podcast.trackCount ?? 0) Episodes"
            
            guard let url = podcast.artworkUrl600 else { return }
            let artworkUrl = URL(string: url)!
            podcastImageView.sd_setImage(with: artworkUrl, placeholderImage: UIImage(named: "appicon"))
            
//            URLSession.shared.dataTask(with: artworkUrl) { data, _, _ in
//                print("Finished downloading image data!", data)
//
//                guard let unwrappedData = data else { return }
//                DispatchQueue.main.async {
//                    self.podcastImageView.image = UIImage(data: unwrappedData)
//                }
//            }.resume()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
