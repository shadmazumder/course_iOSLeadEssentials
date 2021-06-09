//
//  FeedLoader.swift
//  FeedLoader
//
//  Created by SHAD MAZUMDER on 6/9/21.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion : @escaping (LoadFeedResult)-> Void)
}
