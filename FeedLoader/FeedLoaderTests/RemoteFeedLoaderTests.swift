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
        
        sut.load(){ _ in }
        
        XCTAssertEqual(client.requestedURLs.count, 1)
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "www.mobidevtalk.com")!
        let (sut, client) = makeSUT()
        
        sut.load(){ _ in }
        sut.load(){ _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    // TODO: Validate if there is any benifit if we use protocol based rather than the complition
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        var capturedError = [RemoteFeedLoader.Error]()
        sut.load{ capturedError.append($0)}
        
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedError, [.connectivity])
    }

    
    // MARK: - Utility
    private class HttpClientSpy: HttpClient {
        var message = [(url: URL, completion: (Error) -> Void)]()
        
        var requestedURLs: [URL]{
            message.map({$0.url})
        }
        
        func get(from requestedUrl: URL, completion: @escaping (Error)-> Void) {
            message.append((requestedUrl, completion))
        }
        
        
        func complete(with error: Error, at index: Int = 0) {
            message[index].completion(error)
        }
    }
    
    private func makeSUT(url: URL = URL(string: "www.mobidevtalk.com")!) -> (sut: RemoteFeedLoader, client: HttpClientSpy){
        let client = HttpClientSpy()
        let remoteFeedLoader = RemoteFeedLoader(url: url, client: client)
        
        return(remoteFeedLoader, client)
    }
}
