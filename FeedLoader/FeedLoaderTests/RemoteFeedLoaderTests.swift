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
    }
    
    struct HttpClient {
        let requestedUrl: String?
    }
    
    func test_init_loadNoData() {
    let client = HttpClient(requestedUrl: nil)
    
    _ = RemoteFeedLoader(client)
    
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_returnsDataFromUrl() {
    <#given#>
    
    <#when#>
    
    <#then#>
    }
}
