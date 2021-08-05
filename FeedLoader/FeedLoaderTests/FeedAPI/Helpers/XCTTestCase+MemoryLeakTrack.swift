//
//  XCTTestCase+MemoryLeakTrack.swift
//  FeedLoaderTests
//
//  Created by SHAD MAZUMDER on 8/5/21.
//

import XCTest

extension XCTestCase{
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line){
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance is not nil. Potential memory leak.", file: file, line: line)
        }
    }
}
