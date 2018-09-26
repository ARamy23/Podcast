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
    
    fileprivate func handleProgressObservation() -> ((Progress) -> ())
    {
        return { (progress) in
            SVProgressHUD.showProgress(progress.fractionCompleted.float)
            if progress.isFinished
            {
                SVProgressHUD.showSuccess(withStatus: "Download Completed!")
            }
        }
    }
    
    fileprivate func handleSaving(_ episode: Episode) -> ((DefaultDownloadResponse) -> ())
    {
        return { (response) in
            var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
            if let index = downloadedEpisodes.index(where: { $0.title == episode.title && $0.author == episode.author})
            {
                downloadedEpisodes[index].fileURL = response.destinationURL
                
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
        Alamofire.download(episode.streamURL!, to: DownloadRequest.suggestedDownloadDestination())
            .downloadProgress(closure: self.handleProgressObservation())
            .response(completionHandler: self.handleSaving(episode))
    }
}
