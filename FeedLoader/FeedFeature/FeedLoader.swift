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

extension LoadFeedResult: Equatable where Error: Equatable{}

protocol FeedLoader {
    func load(completion : @escaping (LoadFeedResult<Error>)-> Void)
}
