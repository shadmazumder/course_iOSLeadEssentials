//
//  RemoteFeedLoaderTests.swift
//  FeedLoaderTests
//
//  Created by SHAD MAZUMDER on 6/24/21.
//

import XCTest

struct RemoteFeedLoader{
    let client: HttpClient
    let url: URL
    
    func load() {
        client.get(from: url)
    }
}

protocol HttpClient {
    func get(from url: URL)
}

class RemoteFeedLoaderTests: XCTestCase {
    func test_init_loadsNoData() {
        let client = HttpClientSpy()
        
        _ = RemoteFeedLoader(client: client, url: URL(string: "www.mobidevtalk.com")!)
        
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_returnsData() {
        let client = HttpClientSpy()
        let remoteFeedLoader = RemoteFeedLoader(client: client, url: URL(string: "www.mobidevtalk.com")!)
        
        remoteFeedLoader.load()
        
        XCTAssertNotNil(client.requestedUrl)
    }
    
    // MARK: - Utility
    private class HttpClientSpy: HttpClient {
        var requestedUrl: URL?
        
        func get(from requestedUrl: URL) {
            self.requestedUrl = requestedUrl
        }
    }
}
