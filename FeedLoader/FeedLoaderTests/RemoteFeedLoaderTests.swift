//
//  RemoteFeedLoaderTests.swift
//  FeedLoaderTests
//
//  Created by SHAD MAZUMDER on 6/24/21.
//

import XCTest

class RemoteFeedLoaderTests: XCTestCase {
    struct RemoteFeedLoader{
        let client: HttpClient
        
        init(_ client: HttpClient) {
            self.client = client
        }
        
        func load() {
        }
    }
    
    struct HttpClient {
        let requestedUrl: URL?
    }
    
    func test_init_loadsNoData() {
    let client = HttpClient(requestedUrl: nil)
    
    _ = RemoteFeedLoader(client)
    
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_returnsData() {
        let client = HttpClient(requestedUrl: URL(string: "www.mobidevtalk.com"))
        let remoteFeedLoader = RemoteFeedLoader(client)
    
        remoteFeedLoader.load()
    
        XCTAssertNotNil(client.requestedUrl)
    }
}
