//
//  RemoteFeedLoaderTests.swift
//  FeedLoaderTests
//
//  Created by SHAD MAZUMDER on 6/24/21.
//

import XCTest
import FeedLoader

class RemoteFeedLoaderTests: XCTestCase {
    func test_init_loadsNoData() {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_returnsData() {
        let (sut, client) = makeSUT()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedUrl)
    }
    
    // MARK: - Utility
    private class HttpClientSpy: HttpClient {
        var requestedUrl: URL?
        
        func get(from requestedUrl: URL) {
            self.requestedUrl = requestedUrl
        }
    }
    
    private func makeSUT() -> (sut: RemoteFeedLoader, client: HttpClientSpy){
        let client = HttpClientSpy()
        return(RemoteFeedLoader(url: URL(string: "www.mobidevtalk.com")!, client: client), client)
    }
}
