//
//  RemoteFeedLoader.swift
//  FeedLoader
//
//  Created by SHAD MAZUMDER on 7/3/21.
//

import Foundation

public enum HTTPClientResult {
    case success(HTTPURLResponse)
    case fail(Error)
}

public enum Result: Equatable{
    case success
    case failure(RemoteFeedLoader.Error)
}

public protocol HttpClient {
    func get(from requestedUrl: URL, completion: @escaping (HTTPClientResult)-> Void)
}

public struct RemoteFeedLoader{
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
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
            case .success:
                completion(.failure(.invalidData))
            case .fail:
                completion(.failure(.connectivity))
            }
        }
    }
}
