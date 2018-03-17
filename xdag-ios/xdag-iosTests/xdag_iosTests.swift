//
//  xdag_iosTests.swift
//  xdag-iosTests
//
//  Created by yangyin on 2018/2/25.
//  Copyright © 2018年 xdag.org. All rights reserved.
//

import XCTest
@testable import xdag_ios

class xdag_iosTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testXDagQRSchemeTest() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let address = "asdfljas/==342sdfsdf/34234=d90"
        var params = [String:String]()
        params["label"] = "fortest"
        params["amount"] = "3"
        
       var qrScheme = XDagQuerySerialization.encode(address: address, paramsDictionary: params)
        print(qrScheme);
        XCTAssertTrue(qrScheme=="xdag:asdfljas/==342sdfsdf/34234=d90?label=fortest&amount=3", "encode failed")
        
        var (rAddress,rParams) = XDagQuerySerialization.decode(uriScheme: qrScheme)
        print(rAddress!)
        XCTAssertTrue(rAddress! == address, "decode address failed")
        XCTAssertTrue(rParams!["amount"]=="3", "decode params failed")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
