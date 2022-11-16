//
//  RSSFeedExtension.swift
//  PodcastsApp
//
//  Created by Donat Bajrami on 6.6.22.
//

import Foundation
import FeedKit

extension RSSFeed {
    
    func toEpisodes() -> [Episode] {
        let imageUrl = iTunes?.iTunesImage?.attributes?.href
        var episodes = [Episode]()
        
        items?.forEach({ item in
            //print(item.title ?? "")
            var episode = Episode(feedItem: item)
            
            if episode.imageURL == nil {
                episode.imageURL = imageUrl
            }
            episodes.append(episode)
        })
        
        return episodes
    }
}
