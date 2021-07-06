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
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithError: .connectivity) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }

    func test_load_deliversErrorOnNon200HttpResponse() {
        let (sut, client) = makeSUT()
        let non200StatusCodes = [199, 300, 403, 500]
        
        non200StatusCodes.enumerated().forEach(){ (index, statusCode) in
            expect(sut, toCompleteWithError: .invalidData) {
                client.complete(with: statusCode, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HttpResponseWithInvalidJson() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithError: .invalidData) {
            let invalidJson = Data("Invalid Json".utf8)
            client.complete(with: 200, data: invalidJson)
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
        
        func complete(with httpStatusCode: Int, data: Data = Data(), at index: Int = 0) {
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
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithError error: RemoteFeedLoader.Error, when action: ()->Void, file: StaticString = #file, line: UInt = #line ){
        var captureResult = [RemoteFeedLoader.Result]()
        sut.load(completion: {captureResult.append($0)})
        
        action()
        
        XCTAssertEqual(captureResult, [.failure(error)], file: file, line: line)
    }
}
