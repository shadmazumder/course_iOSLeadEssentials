//
//  URLSessionHTTPClient.swift
//  FeedLoader
//
//  Created by SHAD MAZUMDER on 8/24/21.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    struct UnexpectedValueRepresntation: Error {}
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void){
        session.dataTask(with: url) { (data, response, error) in
            if let error = error{
                completion(.fail(error))
            }else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(response, data))
            } else {
                completion(.fail(UnexpectedValueRepresntation()))
            }
        }.resume()
    }
}
