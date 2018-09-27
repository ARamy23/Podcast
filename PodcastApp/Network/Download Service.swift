//
//  Download Service.swift
//  PodcastApp
//
//  Created by ScaRiLiX on 9/26/18.
//  Copyright © 2018 ScaRiLiX. All rights reserved.
//

import Alamofire
import Foundation
import SVProgressHUD

final class DownloadService
{
    typealias DownloadCompleteTuple = (fileURL: URL, episodeTitle: String)
    
    var downloads = [DownloadRequest]()
    
    static let shared = DownloadService()
    
    fileprivate func handleProgressObservation(of episode: Episode) -> ((Progress) -> ())
    {
        return { (progress) in
            
            NotificationCenter.default.post(name: .downloadProgress, object: nil, userInfo: ["title": episode.title ?? "", "progress": progress.fractionCompleted, "isFinished": progress.isFinished])
        }
    }
    
    fileprivate func handleSaving(_ episode: Episode) -> ((DefaultDownloadResponse) -> ())
    {
        return { (response) in
            var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
            if let index = downloadedEpisodes.index(where: { $0.title == episode.title && $0.author == episode.author}), let destinationURL = response.destinationURL
            {
                downloadedEpisodes[index].fileURL = destinationURL
                let episodeDownloadComplete = DownloadCompleteTuple(destinationURL, episode.title ?? "")
                NotificationCenter.default.post(name: .downloadComplete, object: episodeDownloadComplete, userInfo: nil)
                do
                {
                    let data = try JSONEncoder().encode(downloadedEpisodes)
                    UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
                }
                catch let err
                {
                    print(err)
                    SVProgressHUD.showError(withStatus: err.localizedDescription)
                }
            }
        }
    }
    
    func download(_ episode: Episode) {
        UserDefaults.standard.download(episode)
        let download = Alamofire.download(episode.streamURL!, to: DownloadRequest.suggestedDownloadDestination())
            .downloadProgress(closure: self.handleProgressObservation(of: episode))
            .response(completionHandler: self.handleSaving(episode))
        downloads.append(download)
    }
    
    func cancelDownload(at index: Int)
    {
        if downloads.indices.contains(index)
        {
            downloads[index].cancel()
            downloads.remove(at: index)
        }
    }
}
