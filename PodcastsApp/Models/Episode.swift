//
//  Episode.swift
//  PodcastsApp
//
//  Created by Donat Bajrami on 20.5.22.
//

import Foundation
import FeedKit

struct Episode: Codable, Hashable, Equatable {
    let title: String
    let pubDate: Date
    let description: String
    let author: String
    let streamUrl: String
    
    var fileUrl: String?
    var imageURL: String?
    
    init(feedItem: RSSFeedItem) {
        self.streamUrl = feedItem.enclosure?.attributes?.url ?? ""
        self.title = feedItem.title ?? "No title for this podcast 🧐"
        self.pubDate = feedItem.pubDate ?? Date.now
        //self.description = feedItem.iTunes?.iTunesSubtitle ?? feedItem.description ?? "No description for this podcast 🥸"
        self.description = feedItem.description ?? "No description for this podcast 🥸"
        self.author = feedItem.iTunes?.iTunesAuthor ?? "No author avilable 🧐"
        
        self.imageURL = feedItem.iTunes?.iTunesImage?.attributes?.href
    }
    
    static func ==(lhs: Episode, rhs: Episode) -> Bool {
        return lhs.title == rhs.title && lhs.pubDate == rhs.pubDate && lhs.description == rhs.description && rhs.author == lhs.author
    }
}
