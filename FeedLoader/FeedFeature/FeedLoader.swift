//
//  FeedLoader.swift
//  FeedLoader
//
//  Created by SHAD MAZUMDER on 6/9/21.
//

import Foundation

public enum LoadFeedResult<Error: Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    associatedtype Error: Swift.Error
    
    func load(completion : @escaping (LoadFeedResult<Error>)-> Void)
}
