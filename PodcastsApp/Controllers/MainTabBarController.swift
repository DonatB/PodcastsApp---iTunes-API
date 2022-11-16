//
//  MainTabBarController.swift
//  PodcastsApp
//
//  Created by Donat Bajrami on 17.5.22.
//

import Foundation
import UIKit
import MediaPlayer

class MainTabBarController: UITabBarController {
    
    let playerDetailsView = PlayerDetailsView.initFromNib()
    var maximizedTopAnchorConstraint: NSLayoutConstraint!
    var minimizedTopAnchorConstraint: NSLayoutConstraint!
    var bottomAnchorConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().tintColor = .systemTeal
        UITabBar.appearance().tintColor = .systemTeal
        UINavigationBar.appearance().prefersLargeTitles = true
        checkTabbarTransparency()

        viewControllers = [
            createGenericNavController(for: FavoritesController(collectionViewLayout: UICollectionViewFlowLayout()), title: "Favorites", image: "favorites", tag: 0),
            createGenericNavController(for: PodcastsSearchController(), title: "Search", image: "search", tag: 1),
            createGenericNavController(for: DownloadsController(), title: "Downloads", image: "downloads", tag: 2)
        ]
        
        setupPlayerDetailsView()
//        perform(#selector(maximisePlayerDetails), with: nil, afterDelay: 1)
    }
    
    //MARK: - Helper Functions
    
    fileprivate func createGenericNavController(for rootViewController: UIViewController, title: String, image: String, tag: Int) -> UIViewController {
        rootViewController.title = title
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: image)
        navController.tabBarItem.tag = tag
        //        navController.navigationBar.prefersLargeTitles = true
        return navController
    }
    
    fileprivate func setupPlayerDetailsView() {
        print("Setting up PlayerDetailsView")
        
        // use auto layout
        view.insertSubview(playerDetailsView, belowSubview: tabBar)
        
        // enables auto layout
        playerDetailsView.translatesAutoresizingMaskIntoConstraints = false
        
        maximizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        maximizedTopAnchorConstraint.isActive = true
        
        bottomAnchorConstraint = playerDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        minimizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
//        minimizedTopAnchorConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            playerDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            //playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64),
            bottomAnchorConstraint
        ])
    }
    
    @objc func minimizePlayerDetails() {
        maximizedTopAnchorConstraint.isActive = false
        bottomAnchorConstraint.constant = view.frame.height
        minimizedTopAnchorConstraint.isActive = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
            self.tabBar.transform = .identity
            self.tabBar.isHidden = false
            self.playerDetailsView.maximizedStackView.alpha = 0
            self.playerDetailsView.miniPlayerView.alpha = 1
//            self.playerDetailsView.maximizedStackView.isHidden = true
//            self.playerDetailsView.miniPlayerView.isHidden = false
        }
    }
    
    func maximisePlayerDetails(episode: Episode?, playlistEpisodes: [Episode] = []) {
        minimizedTopAnchorConstraint.isActive = false
        maximizedTopAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.constant = 0
        
        bottomAnchorConstraint.constant = 0

        if let episode = episode {
            playerDetailsView.episode = episode
        }
        
        if !playlistEpisodes.isEmpty {
            playerDetailsView.playlistEpisodes = playlistEpisodes
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
            self.tabBar.transform = CGAffineTransform(translationX: 0, y: self.tabBar.frame.height)
            self.tabBar.isHidden = true
            self.playerDetailsView.maximizedStackView.alpha = 1
            self.playerDetailsView.miniPlayerView.alpha = 0
//            self.playerDetailsView.maximizedStackView.isHidden = false
//            self.playerDetailsView.miniPlayerView.isHidden = true
        }
    }
    
    func checkTabbarTransparency() {
        if #available(iOS 13.0, *) {
            let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            UITabBar.appearance().standardAppearance = tabBarAppearance

            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
        }
    }
    
    //    func createFavoriteNavController() -> UINavigationController {
    //        let favoritesVC = ViewController()
    //        favoritesVC.tabBarItem.title = "Favorites"
    //        favoritesVC.tabBarItem.image = UIImage(named: "favorites")
    //        favoritesVC.tabBarItem.tag = 0
    //        favoritesVC.title = "Favorites"
    //
    //        return UINavigationController(rootViewController: favoritesVC)
    //    }
    //
    //    func createSearchNavController() -> UINavigationController {
    //        let SearchVC = ViewController()
    //        SearchVC.tabBarItem.title = "Search"
    //        SearchVC.tabBarItem.image = UIImage(named: "search")
    //        SearchVC.tabBarItem.tag = 1
    //        SearchVC.title = "Search"
    //        let returnedNavVC = UINavigationController(rootViewController: SearchVC)
    //        returnedNavVC.navigationBar.prefersLargeTitles = true
    //
    //        return returnedNavVC
    //    }
    //
    //    func createDownloadsNavController() -> UINavigationController {
    //        let downloadsVC = ViewController()
    //        downloadsVC.tabBarItem.title = "Downloads"
    //        downloadsVC.tabBarItem.image = UIImage(named: "downloads")
    //        downloadsVC.tabBarItem.tag = 2
    //        downloadsVC.title = "Downloads"
    //
    //        return UINavigationController(rootViewController: downloadsVC)
    //    }
}
