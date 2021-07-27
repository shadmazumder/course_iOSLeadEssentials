//
//  FeedLoader.swift
//  FeedLoader
//
//  Created by SHAD MAZUMDER on 6/9/21.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion : @escaping (LoadFeedResult)-> Void)
}
