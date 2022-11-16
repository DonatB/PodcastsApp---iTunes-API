//
//  FavoritePodcastCell.swift
//  PodcastsApp
//
//  Created by Donat Bajrami on 21.7.22.
//

import UIKit

class FavoritePodcastCell: UICollectionViewCell {
    
    let imageView = UIImageView(image: UIImage(named: "appicon"))
    let nameLabel = UILabel()
    let artistNameLabel = UILabel()
    
    var podcast: Podcast! {
        didSet {
            nameLabel.text = podcast.trackName
            artistNameLabel.text = podcast.artistName
            
            if let artworkUrl = podcast.artworkUrl600 {
                imageView.sd_setImage(with: URL(string: artworkUrl))
            } else {
                imageView.image = UIImage(named: "appicon")
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        styleUI()
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func styleUI() {
        nameLabel.text = "Podcast Name"
        nameLabel.textColor = .label
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        artistNameLabel.text = "Artist Name"
        artistNameLabel.textColor = .secondaryLabel
        artistNameLabel.font = UIFont.systemFont(ofSize: 14)
    }
    
    fileprivate func configureViews() {
        let stackView = UIStackView(arrangedSubviews: [imageView, nameLabel, artistNameLabel])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
}
