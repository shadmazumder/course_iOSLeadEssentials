//
//  HttpClient.swift
//  FeedLoader
//
//  Created by SHAD MAZUMDER on 7/7/21.
//

import Foundation

public enum HTTPClientResult {
    case success(HTTPURLResponse, Data)
    case fail(Error)
}

public protocol HttpClient {
    func get(from requestedUrl: URL, completion: @escaping (HTTPClientResult)-> Void)
}
