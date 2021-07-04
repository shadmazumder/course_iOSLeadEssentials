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
        client.error = NSError(domain: "Test", code: 0)
    
        var capturedError: RemoteFeedLoader.Error?
        sut.load{ error in capturedError = error}
        
        XCTAssertEqual(capturedError, .connectivity)
        
    }
    
    // TODO: Validate if there is any benifit if we use protocol based rather than the complition

    
    // MARK: - Utility
    private class HttpClientSpy: HttpClient {
        var requestedURLs = [URL]()
        var error: Error?
        
        func get(from requestedUrl: URL, completion: @escaping (Error)-> Void) {
            if let error = error {
                completion(error)
            }
            requestedURLs.append(requestedUrl)
        }
    }
    
    private func makeSUT(url: URL = URL(string: "www.mobidevtalk.com")!) -> (sut: RemoteFeedLoader, client: HttpClientSpy){
        let client = HttpClientSpy()
        return(RemoteFeedLoader(url: url, client: client), client)
    }
}
