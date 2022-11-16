//
//  EpisodesController.swift
//  PodcastsApp
//
//  Created by Donat Bajrami on 19.5.22.
//

import UIKit
import FeedKit

class EpisodesController: UITableViewController {
    
    var episodes = [Episode]()
    var uniqueList = [Podcast]()
    let favoritedPodcastKey = "favoritedPodcastKey"
    let downloadEpisodesKey = "downloadEpisodesKey"
    let defaults = UserDefaults.standard
    
    var podcast: Podcast? {
        didSet {
            navigationItem.title = podcast?.trackName
            //UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).adjustsFontSizeToFitWidth = true -> Makes navTitle font dynamic.
            fetchEpisodes()
        }
    }
    
    fileprivate let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        setupTableView()
        handleFetchSavedPodcasts()
        setupNavBarButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handleFetchSavedPodcasts()
    }
    
    fileprivate func setupNavBarButtons() {
        guard let podcast = podcast else { return }
        if uniqueList.contains(podcast) {
            navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "heart"), style: .plain, target: self, action: nil)]
        } else {
            navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleSaveFavorite)), UIBarButtonItem(title: "Fetch", style: .plain, target: self, action: #selector(handleFetchSavedPodcasts))]
        }
    }
    
    @objc func handleSaveFavorite() {
        guard let podcast = podcast else { return }
        var listOfPodcasts = uniqueList
        listOfPodcasts.append(podcast)
        print("\n appended element \n")
        listOfPodcasts.forEach({ print($0.collectionName) })
        uniqueList = listOfPodcasts.removingDuplicates()
        print("\n final list \n")
        uniqueList.forEach({ print($0.collectionName) })
        print("Number of elements on this list is \(uniqueList.count)")
        
        if let savedData = try? JSONEncoder().encode(uniqueList) {
            defaults.set(savedData, forKey: favoritedPodcastKey)
            setupNavBarButtons()
        } else {
            print("Failed")
        }
        showBadgeHighlight()
    }
    
    func showBadgeHighlight() {
        UIApplication.mainTabBarController()?.viewControllers?[0].tabBarItem.badgeValue = "New"
    }
    
    @objc func handleFetchSavedPodcasts() {
        if let savedPodcast = defaults.object(forKey: favoritedPodcastKey) as? Data {
            do {
                let decodedData = try JSONDecoder().decode([Podcast].self, from: savedPodcast)
                uniqueList = decodedData
                print("Huzzah!")
                uniqueList.forEach({ print($0.collectionName) })
            } catch {
                print("Nothing saved 😢")
            }
        }
    }
    
    func setupTableView() {
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.register(UINib(nibName: "EpisodeCell", bundle: nil), forCellReuseIdentifier: cellId)
    }
    
    //MARK: - Parse RSS feeds method
    fileprivate func fetchEpisodes() {
        print("Looking for episodes at feed url:", podcast?.feedUrl ?? "")
        
        guard let parserURL = podcast?.feedUrl else { return }
        NetworkManager.shared.fetchEpisodes(feedUrl: parserURL) { [weak self] fetchedEpisodes in
            guard let self = self else { return }
            self.episodes = fetchedEpisodes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

//MARK: - TableView methods

extension EpisodesController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        
        cell.episode = episodes[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let episode = self.episodes[indexPath.row]
        let mainTabbarController = UIApplication.mainTabBarController()
        mainTabbarController?.maximisePlayerDetails(episode: episode, playlistEpisodes: self.episodes)
//        let window = UIApplication.shared.connectedScenes
//                .filter({$0.activationState == .foregroundActive})
//                .compactMap({$0 as? UIWindowScene})
//                .first?.windows
//                .filter({$0.isKeyWindow}).first
//
//        let playerDetailsView = PlayerDetailsView.initFromNib()
//        playerDetailsView.episode = episodes[indexPath.row]
//        playerDetailsView.frame = self.view.frame
//        window?.addSubview(playerDetailsView)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.color = .darkGray
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return episodes.isEmpty ? 200 : 0
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let downloadAction = UIContextualAction(style: .normal, title: "Download", handler: { [weak self] (action, view, success) in
            guard let self = self else { return }
            print("Download")
            let episode = self.episodes[indexPath.row]
            let downloadedEpisodes = self.defaults.fetchDownloadedEpisodes() ?? []
            if !downloadedEpisodes.contains(episode) {
                self.defaults.downloadEpisode(episode: episode)
                NetworkManager.shared.downloadEpisode(episode: episode)
            } else {
                let ac = UIAlertController(title: "Error", message: "This podcast has already been downloaded.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(ac, animated: true)
            }
        
        })
        downloadAction.backgroundColor = .systemMint
        downloadAction.image = UIImage(systemName: "arrow.down.circle.fill")
        return UISwipeActionsConfiguration(actions: [downloadAction])
    }
}

