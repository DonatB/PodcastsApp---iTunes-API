//
//  PodcastsSearchController.swift
//  PodcastsApp
//
//  Created by Donat Bajrami on 17.5.22.
//

import Foundation
import UIKit
import Alamofire

class PodcastsSearchController: UITableViewController {

    var podcasts = [Podcast]()
    
    let cellID = "cellId"
    
    let searchController = UISearchController()
    
    var timer: Timer?
    var firstTime = true
    
    var podcastSearchView = Bundle.main.loadNibNamed("SearchingFooterView", owner: PodcastsSearchController.self, options: nil)?.first as? UIView
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
    }
    
    func setupTableView() {
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        let nib = UINib(nibName: "PodcastCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellID)
    }

}


//MARK: - SearchBar Methods
extension PodcastsSearchController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            firstTime = true
            podcasts = []
            tableView.reloadData()
            return
        }
        print(searchText)
        
        firstTime = false
        podcasts = []
        tableView.reloadData()
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { timer in
            NetworkManager.shared.fetchPodcast(searchText: searchText) { [weak self] returnedPodcasts in
                guard let self = self else { return }
                print("Finished searching for podcasts...")
                self.podcasts = returnedPodcasts
                self.tableView.reloadData()
            }
        })
    }
}


//MARK: - TableView Methods
extension PodcastsSearchController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! PodcastCell
        cell.podcast = podcasts[indexPath.row]
//        cell.textLabel?.numberOfLines = 0
//        cell.textLabel?.text = "\(podcasts[indexPath.row].artistName ?? "Not available")\n\(podcasts[indexPath.row].collectionName)"
//        cell.imageView?.image = UIImage(named: "appicon")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Please enter a search term"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.podcasts.isEmpty && searchController.searchBar.text?.isEmpty == true ? 250 : 0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return podcastSearchView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return podcasts.isEmpty && searchController.searchBar.text?.isEmpty == false ? 200 : 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let episodesController = EpisodesController()
        episodesController.podcast = podcasts[indexPath.row]
        navigationController?.pushViewController(episodesController, animated: true)
    }
}


