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

    func test_load_deliversErrorOnNon200HttpResponse() {
        let (sut, client) = makeSUT()
        let non200StatusCodes = [199, 300, 403, 500]
        
        non200StatusCodes.enumerated().forEach(){ (index, statusCode) in
            var capturedError = [RemoteFeedLoader.Error]()
            sut.load{ capturedError.append($0)}
            
            client.complete(with: statusCode, at: index)
            
            XCTAssertEqual(capturedError, [.invalidData])
        }
    }
    
    // MARK: - Utility
    private class HttpClientSpy: HttpClient {
        var message = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL]{
            message.map({$0.url})
        }
        
        func get(from requestedUrl: URL, completion: @escaping (HTTPClientResult)-> Void) {
            message.append((requestedUrl, completion))
        }
        
        
        func complete(with error: Error, at index: Int = 0) {
            message[index].completion(.fail(error))
        }
        
        func complete(with httpStatusCode: Int, at index: Int = 0) {
            let httpResponse = HTTPURLResponse(url: message[index].url,
                                               statusCode: httpStatusCode,
                                               httpVersion: nil,
                                               headerFields: nil)
            message[index].completion(.success(httpResponse!))
        }
    }
    
    private func makeSUT(url: URL = URL(string: "www.mobidevtalk.com")!) -> (sut: RemoteFeedLoader, client: HttpClientSpy){
        let client = HttpClientSpy()
        let remoteFeedLoader = RemoteFeedLoader(url: url, client: client)
        
        return(remoteFeedLoader, client)
    }
}
