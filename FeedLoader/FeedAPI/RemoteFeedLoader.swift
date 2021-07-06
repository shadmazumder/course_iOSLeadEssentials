//
//  RemoteFeedLoader.swift
//  FeedLoader
//
//  Created by SHAD MAZUMDER on 7/3/21.
//

import Foundation

public enum HTTPClientResult {
    case success(HTTPURLResponse, Data)
    case fail(Error)
}

public protocol HttpClient {
    func get(from requestedUrl: URL, completion: @escaping (HTTPClientResult)-> Void)
}

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
                if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
                    completion(.success(root.items.map({ $0.item })))
                }else{
                    completion(.failure(.invalidData))
                }
            case .fail:
                completion(.failure(.connectivity))
            }
        }
    }
    
    private struct Root: Decodable{
        let items: [Item]
    }
    
    private struct Item: Decodable{
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem{
            return FeedItem(id: id, description: description, location: location, imageUrl: image)
        }
        
    }
}
