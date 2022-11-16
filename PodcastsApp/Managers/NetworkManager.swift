//
//  NetworkManager.swift
//  PodcastsApp
//
//  Created by Donat Bajrami on 18.5.22.
//

import Foundation
import Alamofire
import FeedKit

class NetworkManager {
    static let shared = NetworkManager()
    
    let baseURL = "https://itunes.apple.com/search"
    let decoder = JSONDecoder()
    let defaults = UserDefaults.standard
    
    typealias EpisodeDownloadCompleteTuple = (fileUrl: String, episodeTitle: String)
    
    func fetchPodcast(searchText: String, completionHandler: @escaping ([Podcast]) -> ()) {
        print("Searching for podcast...")
        //https://itunes.apple.com/search?term=name+name&entity=podcast
        let parameters = ["term": searchText, "entity": "podcast"]
        
        AF.request(baseURL, method: .get, parameters: parameters, encoding: URLEncoding.default).responseData { response in
            if let err = response.error {
                print("Failed to contact yahoo", err)
                return
            }
            guard let data = response.data else { return }
            do {
                let returnedData = try JSONDecoder().decode(PodcastResults.self, from: data)
                completionHandler(returnedData.results)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    
    func fetchEpisodes(feedUrl: String, completionHandler: @escaping ([Episode]) -> ()) {
        print("Looking for episodes at feed url:", feedUrl)
        let parser = FeedParser(URL: URL(string: feedUrl.toSecureHTTPs())!)
        
        // Parse asynchronously, not to block the UI.
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { result in
            switch result {
            case .success(let feed):
                print("Feed was parsed succesfully :D", feed)
                switch feed {
                case .rss(let rssFeed):
                    let episodes = rssFeed.toEpisodes()
                    completionHandler(episodes)
                default:
                    break
                }
            case .failure(_):
                print("Feed failed to parse :/")
            }
        }
    }
    
    func downloadEpisode(episode: Episode) {
        print("Downloading episode using Alamofire. ", episode.streamUrl)
        
        let downloadRequest = DownloadRequest.suggestedDownloadDestination()
        
        if let url = URL(string: episode.streamUrl) {
            AF.download(url, to: downloadRequest).downloadProgress { progress in
                print(progress.fractionCompleted)
                //Letting DownloadsController know about my dl progress.
                
                NotificationCenter.default.post(name: .downloadProgress, object: nil, userInfo: ["title": episode.title, "progress": progress.fractionCompleted])
            }.responseData { [weak self] response in
                guard let self = self else { return }
                let episodeDownloadComplete = EpisodeDownloadCompleteTuple(fileUrl: response.fileURL?.absoluteString ?? "", episodeTitle: episode.title)
                NotificationCenter.default.post(name: .downloadComplete, object: episodeDownloadComplete, userInfo: nil)
                if response.fileURL?.absoluteString == nil {
                    print("Already saved once bruh.")
                    return
                }
                print(response.fileURL?.absoluteString ?? "No file url")
                var unwrappedEpisodes = self.defaults.fetchDownloadedEpisodes() ?? []
                guard let index = unwrappedEpisodes.firstIndex (where: { $0.title == episode.title && $0.author == episode.author }) else { return }
                unwrappedEpisodes[index].fileUrl = response.fileURL?.absoluteString
                do {
                    let data = try JSONEncoder().encode(unwrappedEpisodes)
                    self.defaults.set(data, forKey: UserDefaults.downloadEpisodesKey)
                } catch let err {
                    print(err)
                }
            }
        }
    }
    
    
}

extension Notification.Name {
    static let downloadProgress = NSNotification.Name("downloadProgress")
    static let downloadComplete = NSNotification.Name("downloadComplete")
}






