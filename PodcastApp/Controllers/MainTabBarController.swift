//
//  MainTabBarController.swift
//  PodcastApp
//
//  Created by ScaRiLiX on 9/22/18.
//  Copyright © 2018 ScaRiLiX. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController
{
    //MARK:- Helping props
    let playerDetailsView = PlayerDetailsView.initFromNib()
    var maximizedTopAnchorConstraint: NSLayoutConstraint!
    var minimizedTopAnchorConstraint: NSLayoutConstraint!
    var bottomAnchorConstraint: NSLayoutConstraint!
    
    //MARK:- IB Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupVCs()
        setupPlayerDetailsView()
    }
    
    //MARK:- Setup Functions
    
    fileprivate func setupUI()
    {
        tabBar.tintColor =  UIColor.AppPrimaryColor
    }
    
    func setupVCs()
    {        
        viewControllers = [
            generateNavCon(with: PodcastsSearchVC(), for: "Search", and: #imageLiteral(resourceName: "search")),
            generateNavCon(with: FavoritesVC(collectionViewLayout: UICollectionViewFlowLayout()), for: "Favorites", and: #imageLiteral(resourceName: "play")),
            generateNavCon(with: DownloadsVC(), for: "Downloads", and: #imageLiteral(resourceName: "download"))
        ]
    }
    
    fileprivate func setupPlayerDetailsView()
    {
        
        view.insertSubview(playerDetailsView, belowSubview: tabBar)
        
        playerDetailsView.translatesAutoresizingMaskIntoConstraints = false
        
        maximizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.height)
        maximizedTopAnchorConstraint.isActive = true
        
        minimizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        
        playerDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomAnchorConstraint = playerDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.height)
        bottomAnchorConstraint.isActive = true
        playerDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
    }
    
    //MARK:- Helper Functions
    
    fileprivate func generateNavCon(with vc: UIViewController, for title: String, and image: UIImage) -> UIViewController
    {
        let navVC = UINavigationController(rootViewController: vc)
        navVC.navigationBar.topItem?.title = title
        navVC.navigationBar.prefersLargeTitles = true
        navVC.tabBarItem.title = title
        navVC.tabBarItem.image = image
        navVC.navigationBar.tintColor = #colorLiteral(red: 0.4235294118, green: 0.4274509804, blue: 0.7921568627, alpha: 1)
        return navVC
    }
    
    //MARK:- Logic
    func minimizePlayerDetails()
    {
        maximizedTopAnchorConstraint.isActive = false
        bottomAnchorConstraint.constant = view.height
        minimizedTopAnchorConstraint.isActive = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.tabBar.transform = .identity
            self.playerDetailsView.maximizedPlayerStackView.alpha = 0
            self.playerDetailsView.minimizedPlayerView.alpha = 1
        })
    }
    
    func maximizePlayerDetails()
    {
        minimizedTopAnchorConstraint.isActive = false
        maximizedTopAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.constant = 0
        bottomAnchorConstraint.constant = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)
            self.playerDetailsView.maximizedPlayerStackView.alpha = 1
            self.playerDetailsView.minimizedPlayerView.alpha = 0
        })
    }
}
