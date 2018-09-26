//
//  Services.swift
//  PodcastApp
//
//  Created by ScaRiLiX on 9/22/18.
//  Copyright © 2018 ScaRiLiX. All rights reserved.
//

import Foundation
import Moya
import SwifterSwift
import Alamofire


fileprivate let assetDir: URL = {
    let directoryURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return directoryURLs.first ?? URL(fileURLWithPath: NSTemporaryDirectory())
}()

enum Services {
    case search(String)
    case lookup(Int)
    case download(Episode)
}

extension Services: TargetType
{
    var baseURL: URL {
        switch self
        {
        case .download(let episode):
            return episode.streamURL!
        default:
            return "https://itunes.apple.com/".url!
        }
        
    }
    
    var path: String {
        switch self
        {
        case .search(_):
            return ServerPath.search
        case .lookup(_):
            return ServerPath.lookup
        case .download(_):
            return ""
            
        }
    }
    
    var method: Moya.Method {
        switch self
        {
        default:
            return .get
        }
    }
    
    var sampleData: Data {
        switch self
        {
        default:
            return "".utf8Encoded
        }
    }
    
    var task: Task {
        switch self
        {
        case .search(let searchText):
            let params = ["term": searchText]
            return .requestParameters(parameters: params, encoding: Alamofire.URLEncoding.queryString)
        case .lookup(let id):
            let params: [String: Any] = ["id": id, "entitiy": "podcast"]
            return .requestParameters(parameters: params, encoding: Alamofire.URLEncoding.queryString)
        case .download(_):
            return .downloadDestination(downloadDestination)
        }
    }
    
    var assetName: String {
        switch self {
        case .download(let episode):
            return episode.title ?? ""
        default:
            return ""
        }
    }
    
    var localLocation: URL {
        return assetDir.appendingPathComponent(assetName)
    }

    
    var downloadDestination: DownloadDestination {
        return { _, _ in return (self.localLocation, .removePreviousFile) }
    }
    
    var headers: [String : String]? {
        return nil
    }
}

private let DefaultDownloadDestination: DownloadDestination = { temporaryURL, response in
    
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentsURL.appendingPathComponent(response.suggestedFilename!)
    
    let downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
    
    return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
}

private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}


final class AssetLoader {
    let provider = MoyaProvider<Services>()
    
    init() { }
    
    func load(asset: Services, completion: ((Result<URL>) -> Void)? = nil) {
        if FileManager.default.fileExists(atPath: asset.localLocation.path) {
            completion?(.success(asset.localLocation))
            return
        }
        
        provider.request(asset) { result in
            switch result {
            case .success:
                completion?(.success(asset.localLocation))
            case let .failure(error):
                return (completion?(.failure(error)))!
            }
        }
    }
}
