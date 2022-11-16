//
//  DownloadsController.swift
//  PodcastsApp
//
//  Created by Donat Bajrami on 22.7.22.
//

import Foundation
import UIKit

class DownloadsController: UITableViewController {
    
    fileprivate let cellId = "cellId"
    let defaults = UserDefaults.standard
    var downloadedEpisodes = [Episode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let unwrappedEpisodes = defaults.fetchDownloadedEpisodes() ?? []
        downloadedEpisodes = unwrappedEpisodes
        tableView.reloadData()
    }
    
    //MARK: - Setup
    
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }
    
    fileprivate func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(downloadProgress), name: .downloadProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(downloadComplete), name: .downloadComplete, object: nil)
    }
    
    @objc func downloadComplete(notification: Notification) {
        guard let episodeDownloadComplete = notification.object as? NetworkManager.EpisodeDownloadCompleteTuple else { return }
        guard let index = self.downloadedEpisodes.firstIndex(where: { $0.title == episodeDownloadComplete.episodeTitle }) else { return }
        self.downloadedEpisodes[index].fileUrl = episodeDownloadComplete.fileUrl
    }
    
    @objc func downloadProgress(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any] else { return }
        guard let progress = userInfo["progress"] as? Double else { return }
        guard let title = userInfo["title"] as? String else { return }
        
        guard let index = self.downloadedEpisodes.firstIndex(where: { $0.title == title }) else { return }
        guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell else { return }
        
        cell.progressLabel.isHidden = false
        cell.progressLabel.text = "\(Int(progress * 100))%"
        if progress == 1 {
            cell.progressLabel.isHidden = true
        }
    }
    
    //MARK: - UITableView Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadedEpisodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        cell.episode = downloadedEpisodes[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let episode = self.downloadedEpisodes[indexPath.row]
        if episode.fileUrl != nil {
            UIApplication.mainTabBarController()?.maximisePlayerDetails(episode: episode, playlistEpisodes: self.downloadedEpisodes)
        } else {
            let ac = UIAlertController(title: "File URL not found", message: "Cannot find local file", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                UIApplication.mainTabBarController()?.maximisePlayerDetails(episode: episode, playlistEpisodes: self.downloadedEpisodes)
            }))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        134
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: { [weak self] (action, view, success) in
            guard let self = self else { return }
            print("Delete")
            if let fileUrl = self.downloadedEpisodes[indexPath.row].fileUrl {
                guard let url = URL(string: fileUrl) else { return }
                let pathComponent = url.lastPathComponent
                guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                trueLocation.appendPathComponent(pathComponent)
                try? FileManager.default.removeItem(at: trueLocation)
            }
            self.downloadedEpisodes.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            if let updatedList = try? JSONEncoder().encode(self.downloadedEpisodes) {
                self.defaults.set(updatedList, forKey: UserDefaults.downloadEpisodesKey)
            } else {
                print("Failed")
            }
        })
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "minus.circle.fill")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
}
