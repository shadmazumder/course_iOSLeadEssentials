//
//  RemoteFeedLoader.swift
//  FeedLoader
//
//  Created by SHAD MAZUMDER on 7/3/21.
//

import Foundation

public class RemoteFeedLoader: FeedLoader{
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion : @escaping (LoadFeedResult)-> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else {return}
            
            switch result{
            case let .success(response, data):
                completion(FeedItemMapper.map(data, from: response))
            case .fail:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
