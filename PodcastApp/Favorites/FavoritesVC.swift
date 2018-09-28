//
//  ViewController.swift
//  PodcastApp
//
//  Created by ScaRiLiX on 9/22/18.
//  Copyright © 2018 ScaRiLiX. All rights reserved.
//

import UIKit

class FavoritesVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    //MARK:- Datasource
    var podcasts = UserDefaults.standard.savedPodcasts()
    
    //MARK:- View Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        podcasts = UserDefaults.standard.savedPodcasts()
        collectionView.reloadData()
        UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = nil
    }
    
    //MARK:- Setup Methods
    
    fileprivate func setupCollectionView()
    {
        collectionView.backgroundColor = .white
        collectionView.register(nibWithCellClass: FavoritesCell.self)
        collectionView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleDelete)))
    }
    
    //MARK:- Logic
    
    @objc fileprivate func handleDelete(gesture: UILongPressGestureRecognizer)
    {
        let location = gesture.location(in: collectionView)
        guard let selectedIndexPath = collectionView.indexPathForItem(at: location) else { return }
        
        let alertController = UIAlertController(title: "Remove Podcast?", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
            self.podcasts.remove(at: selectedIndexPath.item)
            self.collectionView.deleteItems(at: [selectedIndexPath])
            UserDefaults.standard.save(self.podcasts)
        }))
        
        alertController.addAction(UIAlertAction(title: "No", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    //MARK:- CollectionView Methods
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        podcasts.isEmpty ? collectionView.setEmptyMessage("Nope, nothing here\nSorry!") : collectionView.restore()
        
        
        return podcasts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: FavoritesCell.self, for: indexPath)
        let podcast = podcasts[indexPath.row]
        cell.podcast = podcast
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sideLength = (self.view.width - 3 * 16) / 2
        return CGSize(width: sideLength , height: sideLength)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let episodeVC = EpisodesVC()
        let cell = collectionView.cellForItem(at: indexPath) as! FavoritesCell
        episodeVC.podcast = podcasts[indexPath.row]
        episodeVC.podcastImage = cell.podcastImageView.image
        navigationController?.pushViewController(episodeVC, animated: true)
    }
}

