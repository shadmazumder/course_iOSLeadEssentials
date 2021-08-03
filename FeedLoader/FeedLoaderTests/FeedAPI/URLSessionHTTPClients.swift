//
//  URLSessionHTTPClients.swift
//  FeedLoaderTests
//
//  Created by SHAD MAZUMDER on 7/30/21.
//

import XCTest
import FeedLoader

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

class URLSessionHTTPClient {
    private let session: HTTPSession
    
    init(session: HTTPSession) {
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

    func test_getFromURL_resumsDataTaskWithURL() {
        let url = URL(string: "https://a-url.com")!
        let session = HTTPSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(session: session)

        sut.get(from: url){_ in}
        
        XCTAssertEqual(task.resumeCallcounter, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "https://a-url.com")!
        let session = HTTPSessionSpy()
        let error = NSError(domain: "Some Domain", code: 0)
        session.stub(url: url, error: error)
        
        let sut = URLSessionHTTPClient(session: session)
        
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
    }
    
    // MARK: - Helper Entity
    private class HTTPSessionSpy: HTTPSession {
        struct Stubs {
            let dataTask: URLSessionDataTask
            let error: Error?
        }
        
        private var stubs = [URL: Stubs]()
        
        func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil){
            stubs[url] = Stubs(dataTask: task, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("stub is missing for the url: \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stub.dataTask
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask{
        override init() {}
    }
    
    private class URLSessionDataTaskSpy: URLSessionDataTask{
        var resumeCallcounter = 0

        override init() {}
        
        override func resume() {
            resumeCallcounter += 1
        }
    }
}
