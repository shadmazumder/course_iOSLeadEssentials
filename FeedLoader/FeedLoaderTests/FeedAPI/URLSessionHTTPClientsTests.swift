//
//  URLSessionHTTPClientsTests.swift
//  FeedLoaderTests
//
//  Created by SHAD MAZUMDER on 7/30/21.
//

import XCTest
import FeedLoader

class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    struct UnexpectedValueRepresntation: Error {}
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void){
        session.dataTask(with: url) { (data, response, error) in
            if let error = error{
                completion(.fail(error))
            }else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(response, data))
            } else {
                completion(.fail(UnexpectedValueRepresntation()))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequest()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_getFromURL_failsOnRequestError() {
        let requestError = NSError(domain: "Some Domain", code: 0)
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)
        
        XCTAssertEqual(receivedError as NSError?, requestError)
    }
    
    func test_getFromURL_performsGetActionWithURL() {
        let url = anyUrl()
        let exp = expectation(description: "Wait for request")
        
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        wait(for: [exp], timeout: 1)
    }
    
    func test_getFromURL_failsOnAllInvalidResponseCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
    
    func test_getFromURL_successedsOnHTTPURLResponseWithData() {
        let requestedData = anyData()
        let requestedResponse = anyHTTPURLResponse()
        
        let receivedResult = resultValueFor(data: requestedData, response: requestedResponse, error: nil)
        
        XCTAssertEqual(requestedData, receivedResult?.data)
        XCTAssertEqual(requestedResponse.url, receivedResult?.response.url)
        XCTAssertEqual(requestedResponse.statusCode, receivedResult?.response.statusCode)
    }
    
    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let requestedResponse = anyHTTPURLResponse()
        let receivedResult = resultValueFor(data: nil, response: requestedResponse, error: nil)
        XCTAssertEqual(Data(), receivedResult?.data)
        XCTAssertEqual(requestedResponse.url, receivedResult?.response.url)
        XCTAssertEqual(requestedResponse.statusCode, receivedResult?.response.statusCode)
    }
    
    // MARK: - Helper Entity
    private func anyUrl() -> URL{
        return URL(string: "https://any-url.com")!
    }
    
    private func makeSUT() -> HTTPClient{
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func resultValueFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let receivedResult = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch receivedResult{
        case let .success(receivedResponse, receivedData):
            return(receivedData, receivedResponse)
        default:
            XCTFail("Was expecting success but got \(receivedResult)")
            return nil
        }
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error? , file: StaticString = #file, line: UInt = #line) -> Error? {
        let receivedResult = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch receivedResult{
        case let .fail(error):
            return error
        default:
            XCTFail("Was expecting fail but got \(receivedResult)", file: file, line: line)
            return nil
        }
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> HTTPClientResult {
        
        URLProtocolStub.stub(response: response, data: data, error: error)
        let sut = makeSUT()
        let exp = expectation(description: "Wait for result")
        var receivedResult: HTTPClientResult!
        
        sut.get(from: anyUrl()) { (result) in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return receivedResult
    }
    
    private func anyNSError() -> NSError{
        return NSError(domain: "Any Error", code: 0)
    }
    
    private func anyData() -> Data{
        return Data("Any Data".utf8)
    }
    
    private func nonHTTPURLResponse() -> URLResponse{
        return URLResponse(url: anyUrl(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse()  -> HTTPURLResponse{
        return HTTPURLResponse(url: anyUrl(), statusCode: 0, httpVersion: nil, headerFields: nil)!
    }
    
    private class URLProtocolStub: URLProtocol {
        struct Stub {
            let response: URLResponse?
            let data: Data?
            let error: Error?
        }
        
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        static func stub(response: URLResponse?, data: Data?, error: Error?){
            stub = Stub(response: response, data: data, error: error)
        }
        
        static func observeRequest(observer: @escaping (URLRequest) -> Void){
            requestObserver = observer
        }
        
        static func startInterceptingRequest(){
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest(){
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override func startLoading() {
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
