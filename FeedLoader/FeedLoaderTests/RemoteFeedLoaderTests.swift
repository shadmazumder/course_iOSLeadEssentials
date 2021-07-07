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
                client.complete(with: statusCode,data: makeItemJson(items: []) ,at: index)
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
    
    func test_load_deliversEmptyItemOn200HttpResponseWithEmptyJsonList() {
        let (sut, client) = makeSUT()
        var captureResult = [RemoteFeedLoader.Result]()

        sut.load(){captureResult.append($0)}
        
        client.complete(with: 200,data: makeItemJson(items: []))

        XCTAssertEqual(captureResult, [.success([])])
    }
    
    func test_load_deliversFeedItemsOn200HttpResponseWithJsonItems() {
        let (sut, client) = makeSUT()
        var captureResult = [RemoteFeedLoader.Result]()

        let item1 = makeItem(id: UUID(), imageUrl: URL(string: "a-given-url.com")!)
        let item2 = makeItem(id: UUID(), description: "A given description", imageUrl: URL(string: "another-given-url.com")!)
        
        sut.load(){captureResult.append($0)}
        
        client.complete(with: 200,
                        data: makeItemJson(items: [item1.json, item2.json]))

        XCTAssertEqual(captureResult, [.success([item1.model, item2.model])])
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
        
        func complete(with httpStatusCode: Int, data: Data, at index: Int = 0) {
            let httpResponse = HTTPURLResponse(url: message[index].url,
                                               statusCode: httpStatusCode,
                                               httpVersion: nil,
                                               headerFields: nil)
            message[index].completion(.success(httpResponse!, data))
        }
    }
    
    private func makeSUT(url: URL = URL(string: "www.mobidevtalk.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HttpClientSpy){
        let client = HttpClientSpy()
        let remoteFeedLoader = RemoteFeedLoader(url: url, client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        
        return(remoteFeedLoader, client)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line){
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance is not nil. Potential memory leak.", file: file, line: line)
        }
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageUrl: URL) -> (model: FeedItem, json: [String: Any]){
        let item = FeedItem(id: id, description: description, location: location, imageUrl: imageUrl)
        let json = [
            "id": item.id.uuidString,
            "description": item.description,
            "location" : item.location,
            "image": item.imageUrl.absoluteString
        ].compactMapValues({$0}).reduce(into: [String: Any](), { $0[$1.key] = $1.value })
        
        return (item, json)
    }
    
    private func makeItemJson(items: [[String: Any]]) -> Data {
        let json = ["items" : items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithError error: RemoteFeedLoader.Error, when action: ()->Void, file: StaticString = #file, line: UInt = #line ){
        var captureResult = [RemoteFeedLoader.Result]()
        sut.load(completion: {captureResult.append($0)})
        
        action()
        
        XCTAssertEqual(captureResult, [.failure(error)], file: file, line: line)
    }
}
