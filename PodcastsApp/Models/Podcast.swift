//
//  Podcast.swift
//  PodcastsApp
//
//  Created by Donat Bajrami on 18.5.22.
//

import Foundation

struct Podcast: Codable, Hashable {
    let artistName: String?
    let collectionName: String
    let trackName: String?
    let country: String
    let currency: String
    let artworkUrl600: String?
    let trackCount: Int?
    let feedUrl: String?
}
