//
//  RemoteFeedLoader.swift
//  FeedLoader
//
//  Created by SHAD MAZUMDER on 7/3/21.
//

import Foundation

public struct RemoteFeedLoader{
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable{
        case success([FeedItem])
        case failure(Error)
    }
    
    private let url: URL
    private let client: HttpClient
    
    public init(url: URL, client: HttpClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result)-> Void) {
        client.get(from: url) { result in
            switch result{
            case let .success(response, data):
                do {
                    let item = try FeedItemMapper.map(response: response, data: data)
                    completion(.success(item))
                } catch {
                    completion(.failure(.invalidData))
                }
            case .fail:
                completion(.failure(.connectivity))
            }
        }
    }
}
