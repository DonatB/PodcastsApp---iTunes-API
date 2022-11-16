//
//  PodcastResults.swift
//  PodcastsApp
//
//  Created by Donat Bajrami on 18.5.22.
//

import Foundation

class PodcastResults: Codable {
    let resultCount: Int
    let results: [Podcast]
}
