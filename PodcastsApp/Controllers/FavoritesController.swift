//
//  FavoritesController.swift
//  PodcastsApp
//
//  Created by Donat Bajrami on 21.7.22.
//

import Foundation
import UIKit

class FavoritesController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    fileprivate let cellId = "cellId"
    let favoritedPodcastKey = "favoritedPodcastKey"
    let defaults = UserDefaults.standard
    var favoritedPodcasts = [Podcast]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let fetchedPodcasts = fetchDataFromDefaults() else { return }
        favoritedPodcasts = fetchedPodcasts
        collectionView.reloadData()
        UIApplication.mainTabBarController()?.viewControllers?[0].tabBarItem.badgeValue = nil
    }
    
    fileprivate func setupCollectionView() {
        collectionView.register(FavoritePodcastCell.self, forCellWithReuseIdentifier: cellId)
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        collectionView.addGestureRecognizer(gesture)
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: collectionView)
        let selectedIndexPath = collectionView.indexPathForItem(at: location)
        guard let selectedIndexPath = selectedIndexPath else { return }
        
        let ac = UIAlertController(title: "Remove Podcast?", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            self.favoritedPodcasts.remove(at: selectedIndexPath.item)
            self.collectionView.deleteItems(at: [selectedIndexPath])
            if let updatedList = try? JSONEncoder().encode(self.favoritedPodcasts) {
                self.defaults.set(updatedList, forKey: self.favoritedPodcastKey)
            } else {
                print("Failed")
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func fetchDataFromDefaults() -> [Podcast]? {
        if let savedPodcast = defaults.object(forKey: favoritedPodcastKey) as? Data {
            do {
                let decodedData = try JSONDecoder().decode([Podcast].self, from: savedPodcast)
                return decodedData
            } catch {
                print("Nothing saved 😢")
                return nil
            }
        }
        return nil
    }
    
    
    //MARK: - UICollectionView Methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoritedPodcasts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FavoritePodcastCell
        cell.podcast = favoritedPodcasts[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3 * 16) / 2
        return CGSize(width: width, height: width + 46)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let episodesController = EpisodesController()
        episodesController.podcast = self.favoritedPodcasts[indexPath.item]
        navigationController?.pushViewController(episodesController, animated: true)
    }
    
}
