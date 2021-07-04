//
//  RemoteFeedLoaderTests.swift
//  FeedLoaderTests
//
//  Created by SHAD MAZUMDER on 6/24/21.
//

import XCTest
import FeedLoader

class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs.count, 1)
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "www.mobidevtalk.com")!
        let (sut, client) = makeSUT()
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        var capturedError = [RemoteFeedLoader.Error]()
        sut.load{ capturedError.append($0)}
        
        let clientError = NSError(domain: "Test", code: 0)
        client.complitions[0](clientError)
        
        XCTAssertEqual(capturedError, [.connectivity])
    }
    
    // TODO: Validate if there is any benifit if we use protocol based rather than the complition

    
    // MARK: - Utility
    private class HttpClientSpy: HttpClient {
        var requestedURLs = [URL]()
        var complitions = [(Error) -> Void]()
        
        func get(from requestedUrl: URL, completion: @escaping (Error)-> Void) {
            complitions.append(completion)
            requestedURLs.append(requestedUrl)
        }
    }
    
    private func makeSUT(url: URL = URL(string: "www.mobidevtalk.com")!) -> (sut: RemoteFeedLoader, client: HttpClientSpy){
        let client = HttpClientSpy()
        return(RemoteFeedLoader(url: url, client: client), client)
    }
}
