//
//  URLSessionHTTPClients.swift
//  FeedLoaderTests
//
//  Created by SHAD MAZUMDER on 7/30/21.
//

import XCTest
import FeedLoader

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void){
        session.dataTask(with: url) { (_, _, error) in
            if let error = error{
                completion(.fail(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    func test_getFromURL_failsOnRequestError() {
        URLProtocolStub.startInterceptingRequest()
        
        let url = URL(string: "https://a-url.com")!
        let error = NSError(domain: "Some Domain", code: 0)
        URLProtocolStub.stub(url: url, response: nil, data: nil, error: error)
        
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "Wait for completion")
        
        sut.get(from: url){ result in
            switch result{
                case let .fail(receivedError as NSError):
                    XCTAssertEqual(error, receivedError)
            default:
                XCTFail("Expected failure with \(error) got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        URLProtocolStub.stopInterceptingRequest()
    }
    
    // MARK: - Helper Entity
    private class URLProtocolStub: URLProtocol {
        struct Stub {
            let response: URLResponse?
            let data: Data?
            let error: Error?
        }
        
        private static var stub: Stub?
        
        static func stub(url: URL, response: URLResponse?, data: Data?, error: Error?){
            stub = Stub(response: response, data: data, error: error)
        }
        
        static func startInterceptingRequest(){
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest(){
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
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
