//
//  EpisodesVC.swift
//  PodcastApp
//
//  Created by ScaRiLiX on 9/23/18.
//  Copyright © 2018 ScaRiLiX. All rights reserved.
//

import UIKit
import FeedKit
import Moya
import Alamofire
import SVProgressHUD

class EpisodesVC: UITableViewController {
    
    // MARK:- Instance Variables
    
    let provider = MoyaProvider<Services>(plugins: [NetworkLoggerPlugin(verbose: true)])
    
    var podcast: Podcast?
    {
        didSet
        {
            navigationItem.title = podcast?.trackName ?? "Episodes"
            getEpisodes()
        }
    }
    
    var episodes = [Episode]()
    var podcastImage: UIImage?
    
    //MARK:- View Controller Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavBarButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBarButtons()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SVProgressHUD.dismiss()
    }
    //MARK:- Setup Methods
    
    fileprivate func setupNavBarButtons()
    {
        let savedPodcasts = UserDefaults.standard.savedPodcasts()
        let hasFavorited = savedPodcasts.index(where: { $0.trackName == self.podcast?.trackName && $0.artistName == self.podcast?.artistName }) != nil
        if hasFavorited
        {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "faved"), landscapeImagePhone: #imageLiteral(resourceName: "faved"), style: .plain, target: nil, action: nil)
        }
        else
        {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "notFaved"), landscapeImagePhone: #imageLiteral(resourceName: "notFaved"), style: .plain, target: self, action: #selector(handleFavoritingPodcast))
        }
    }
    
    fileprivate func setupTableView()
    {
        tableView.register(nibWithCellClass: EpisodeCell.self)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }

    //MARK:- Logic
    
    fileprivate func updateNavBarIcon()
    {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "faved"), landscapeImagePhone: #imageLiteral(resourceName: "faved"), style: .plain, target: nil, action: nil)
    }
    
    fileprivate func highlightFavoritesBadge()
    {
        UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = "+New"
    }
    
    @objc fileprivate func handleFetchingSavedPodcasts()
    {
        guard let data = UserDefaults.standard.data(forKey: UserDefaults.savedPodcastsKey) else { return }
        do
        {
            let podcasts = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Podcast]
            podcasts?.forEach { print($0.trackName ?? "NIL") }
        }
        catch (let err)
        {
            SVProgressHUD.showError(withStatus: err.localizedDescription)
            print(err)
        }
    }
    
    @objc fileprivate func handleFavoritingPodcast()
    {
        guard let podcast = self.podcast else { return }
        
        var podcasts = UserDefaults.standard.savedPodcasts()
        podcasts.append(podcast)
        
        UserDefaults.standard.save(podcasts)
        highlightFavoritesBadge()
        updateNavBarIcon()
    
        
    }
    
    //MARK:- Network Methods
    
    fileprivate func getEpisodes()
    {
        lookup(trackID: podcast?.trackID ?? 0)
    }
    
    fileprivate func lookup(trackID: Int)
    {
        SVProgressHUD.show(withStatus: "Fetching Episodes...")
        provider.request(.lookup(trackID)) { (result) in
            switch result
            {
            case .success(let response):
                self.parseAndFetchEpisodes(from: response.data)
            case .failure(let err):
                SVProgressHUD.showError(withStatus: err.localizedDescription)
            }
        }
    }
    
    fileprivate func parseAndFetchEpisodes(from data: Data)
    {
        do
        {
            let searchResults = try JSONDecoder().decode(SearchResult.self, from: data)
            if let podcasts = searchResults.results, !podcasts.isEmpty
            {
                var filteredPodcast: Podcast?
                podcasts.forEach { if $0.trackID == self.podcast?.trackID { filteredPodcast = $0 } }
                if let feedURL = filteredPodcast?.feedURL?.url
                {
                    DispatchQueue.global(qos: .background).async
                    {
                        let feedParser = FeedParser(URL: feedURL)
                        feedParser.parseAsync(result: { (feedResult) in
                            switch feedResult
                            {
                                
                            case .rss(let feed):
                                var episodes = [Episode]()
                                feed.items?.forEach { episodes.append(
                                    Episode(feedItem: $0)) }
                                self.episodes = episodes
                                
                                DispatchQueue.main.async
                                {
                                    self.tableView.reloadData()
                                    SVProgressHUD.dismiss()
                                }
                                
                                
                            case .failure(let err):
                                print(err.localizedDescription)
                                break
                            default:
                                break
                            }
                        })
                    }
                }
                else
                {
                    SVProgressHUD.showError(withStatus: "We Don't Support This Track at the moment")
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else
            {
                SVProgressHUD.showError(withStatus: "This Podcast doesn't have any Episodes Yet...")
                self.navigationController?.popViewController(animated: true)
            }
        }
        catch (let err)
        {
            SVProgressHUD.showError(withStatus: err.localizedDescription)
            print(err)
        }
    }
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withClass: EpisodeCell.self)
        
        let episode = episodes[indexPath.row]
        
        cell.episode = episode
        cell.podcastImage = podcastImage
        cell.separatorInset = .zero
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = episodes[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as! EpisodeCell
        
        let mainTabBarController = UIApplication.mainTabBarController()
        
        mainTabBarController?.maximizePlayerDetails()
        mainTabBarController?.playerDetailsView.episode = episode
        mainTabBarController?.playerDetailsView.episodeImageView.image = cell.episodeImageView.image
        mainTabBarController?.playerDetailsView.minimizedEpisodeImageView.image = cell.episodeImageView.image
        mainTabBarController?.playerDetailsView.podcastEpisodes = episodes
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let downloadAction = UITableViewRowAction(style: .normal, title: "Download") { (_, _) in
            let episode = self.episodes[indexPath.row]
            UserDefaults.standard.download(episode)
            let provider = MoyaProvider<Services>(plugins: [NetworkLoggerPlugin(verbose: true)])
            provider.request(.download(episode), callbackQueue: nil, progress: { (progress) in
                SVProgressHUD.showProgress(progress.progress.float)
            }, completion: { (response) in
                response.value.d
            })
        }
        
        
        downloadAction.backgroundColor = Constants.Colors.primaryColor
        return [downloadAction]
    }
}
