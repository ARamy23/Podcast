//
//  DownloadsVC.swift
//  PodcastApp
//
//  Created by ScaRiLiX on 9/26/18.
//  Copyright © 2018 ScaRiLiX. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire

class DownloadsVC: UITableViewController {

    var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
        tableView.reloadData()
        UIApplication.mainTabBarController()?.viewControllers?[2].tabBarItem.badgeValue = nil
    }
    
    //MARK:- Setup Methods
    
    fileprivate func setupObservers()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadCompletion), name: .downloadComplete, object: nil)
    }
    
    fileprivate func setupTableView()
    {
        tableView.register(nibWithCellClass: DownloadCell.self)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }

    //MARK:- Logic
    
    @objc fileprivate func handleDownloadCompletion(notification: Notification)
    {
        guard let episodeDownloadComplete = notification.object as? DownloadService.DownloadCompleteTuple else { return }
        guard let index = downloadedEpisodes.index(where: { $0.title == episodeDownloadComplete.episodeTitle } ) else { return }
        self.downloadedEpisodes[index].fileURL = episodeDownloadComplete.fileURL
        
    }
    
    @objc fileprivate func handleDownloadProgress(notification: Notification)
    {
        guard let userInfo = notification.userInfo else { return }
        guard let progress = userInfo["progress"] as? Double else { return }
        guard let title = userInfo["title"] as? String else { return }
        guard let index = downloadedEpisodes.index(where: { $0.title == title } ) else { return }
        guard let isFinished = userInfo["isFinished"] as? Bool else { return }
        
        let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as! DownloadCell
        cell.progressLabel.isHidden = isFinished
        cell.progressLabel.text = "\(Int(progress * 100))%"
        cell.progressLabel.backgroundColor = UIColor.AppPrimaryColor.withAlphaComponent(1.0 - progress.cgFloat)
    }
    
    fileprivate func play(_ episode: Episode, at indexPath: IndexPath)
    {
        let cell = tableView.cellForRow(at: indexPath) as! DownloadCell
        let mainTabBarController = UIApplication.mainTabBarController()
        
        mainTabBarController?.maximizePlayerDetails()
        mainTabBarController?.playerDetailsView.episode = episode
        mainTabBarController?.playerDetailsView.episodeImageView.image = cell.episodeImageView.image
        mainTabBarController?.playerDetailsView.minimizedEpisodeImageView.image = cell.episodeImageView.image
        mainTabBarController?.playerDetailsView.podcastEpisodes = downloadedEpisodes
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return downloadedEpisodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: DownloadCell.self)
        
        let episode = downloadedEpisodes[indexPath.row]
        cell.episode = episode
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "You have not downloaded anything yet..."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        label.textColor = UIColor.AppPrimaryColor
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return downloadedEpisodes.count > 0 ? 0 : 300
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, _) in
            UserDefaults.standard.remove(self.downloadedEpisodes[indexPath.row])
            self.downloadedEpisodes.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            DownloadService.shared.cancelDownload(at: indexPath.row)
        }
        
        return [deleteAction]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let episode = downloadedEpisodes[indexPath.row]
        
        if episode.fileURL != nil
        {
            play(episode, at: indexPath)
        }
        else
        {
            let alert = UIAlertController(title: "Download is in-completed", message: "Would you like to re-download or listen to the episode online?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Re-download", style: .default, handler: { (_) in
                DownloadService.shared.download(episode)
            }))
            alert.addAction(UIAlertAction(title: "Listen online", style: .default, handler: { (_) in
                self.play(episode, at: indexPath)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            alert.show(animated: true, vibrate: true, completion: nil)
        }
    }
}
