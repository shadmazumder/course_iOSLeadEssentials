//
//  URLSessionHTTPClients.swift
//  FeedLoaderTests
//
//  Created by SHAD MAZUMDER on 7/30/21.
//

import XCTest
import FeedLoader

struct UnexpectedValueRepresntation: Error {}

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void){
        session.dataTask(with: url) { (data, response, error) in
            if let error = error{
                completion(.fail(error))
            }else{
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
        let error = NSError(domain: "Some Domain", code: 0)
        URLProtocolStub.stub(response: nil, data: nil, error: error)
        
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion")
        
        sut.get(from: anyUrl()){ result in
            switch result{
                case let .fail(receivedError as NSError):
                    XCTAssertEqual(error, receivedError)
            default:
                XCTFail("Expected failure with \(error) got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
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
    
    func test_getFromURL_failsOnAllNilValues() {
        URLProtocolStub.stub(response: nil, data: nil, error: nil)
        let exp = expectation(description: "Wait for fail result")
        
        makeSUT().get(from: anyUrl()) { result in
            switch result{
            case.fail:
                break
            default:
                XCTFail("Was expecting fail but got \(result)")
            }
            exp.fulfill()
        }
    
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helper Entity
    private func anyUrl() -> URL{
        return URL(string: "https://any-url.com")!
    }
    
    private func makeSUT() -> URLSessionHTTPClient{
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut)
        return sut
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
