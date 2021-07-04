//
//  RemoteFeedLoader.swift
//  FeedLoader
//
//  Created by SHAD MAZUMDER on 7/3/21.
//

import Foundation

public protocol HttpClient {
    func get(from url: URL, completion: @escaping (HTTPURLResponse?, Error?)-> Void)
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
    
    public func load(completion: @escaping (Error)-> Void) {
        client.get(from: url) { (httpResponse, error) in
            if httpResponse != nil{
                completion(.invalidData)
            }else{
                completion(.connectivity)
            }
        }
    }
}
