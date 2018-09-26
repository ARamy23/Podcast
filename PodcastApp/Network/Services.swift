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
            return Constants.NetworkSettings.mainURL.url!
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
            return .downloadDestination(DownloadRequest.suggestedDownloadDestination())
        }
    }
    
    
    var headers: [String : String]? {
        return nil
    }
}

private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}
