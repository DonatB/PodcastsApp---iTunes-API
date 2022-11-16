//
//  UserDefaultsExtension.swift
//  PodcastsApp
//
//  Created by Donat Bajrami on 21.7.22.
//

import Foundation

extension UserDefaults {

    static let downloadEpisodesKey = "downloadEpisodesKey"
    
    func downloadEpisode(episode: Episode) {
        var downloadedEpisodes = fetchDownloadedEpisodes() ?? []
        downloadedEpisodes.insert(episode, at: 0)
        let episodesToDownload = downloadedEpisodes.removingDuplicates()
        if let data = try? JSONEncoder().encode(episodesToDownload) {
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadEpisodesKey)
        } else {
            print("Failed")
        }
    }
    
    func fetchDownloadedEpisodes() -> [Episode]? {
        if let savedPodcast = UserDefaults.standard.object(forKey: UserDefaults.downloadEpisodesKey) as? Data {
            do {
                let decodedData = try JSONDecoder().decode([Episode].self, from: savedPodcast)
                return decodedData
            } catch {
                print("Nothing saved 😢")
            }
        }
        return nil
    }
}
