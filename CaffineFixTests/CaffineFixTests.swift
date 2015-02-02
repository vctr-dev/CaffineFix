//
//  CaffineFixTests.swift
//  CaffineFixTests
//
//  Created by Victor Chan on 31/1/15.
//  Copyright (c) 2015 Spark Plug Studio. All rights reserved.
//

import UIKit
import XCTest
import CaffineFix

class CaffineFixTests: XCTestCase {
    let mockLL = "37.33240905,-122.03051211"
    let mockVenueId = "4dd1a2d652b15d0acc6c89dd"
    let coffeeListTableViewController = CoffeeListTableViewController()
    let coffeeDetailTableViewController = CoffeeDetailTableViewController()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitializing(){
        XCTAssertNotNil(coffeeListTableViewController, "Coffee List Table View Controller did not load")
        XCTAssertNotNil(coffeeListTableViewController, "Coffee Detail Table View Controller did not load")
    }
    
    func testGettingVenuesFromServer(){
        if let url = coffeeListTableViewController.exploreUrl(mockLL){
            let urlRequest = NSURLRequest(URL: url)
            let expectation = expectationWithDescription("Get json for explore API with url: \(url)")
            NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler:{urlResponse, data, error in
                expectation.fulfill()
                
                XCTAssertNotNil(data, "data should not be nil")
                XCTAssertNil(error, "error should be nil")
                
                if let response = urlResponse as? NSHTTPURLResponse {
                    XCTAssertEqual(response.statusCode, 200, "HTTP response status code should be 200")
                    XCTAssertEqual(response.MIMEType!, "application/json", "HTTP response content type should be application/json")
                } else {
                    XCTFail("Response was not NSHTTPURLResponse")
                }
                
                var error: NSError?
                let jsonDict: NSDictionary? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as? NSDictionary
                XCTAssertNotNil(jsonDict, "\(__FUNCTION__): JSONObjectWithData error: \(error)")
            })
            
            waitForExpectationsWithTimeout(60, handler: { error in
            })
        }else{
            XCTFail("Explore URL fail to create")
        }
        
    }
    
    func getJsonDataFromFileName(fileName:String)->NSData?{
        let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "")
        if let jsonPath = path {
            let mockJson = NSData(contentsOfFile: jsonPath)
            return mockJson
        }
        return nil
    }
    
    func testExtractingVenuesFromJson(){
        //Using mock json, test if venue can be extracted properly using extractVenue function
        if let json = getJsonDataFromFileName("exploreResultMocked"){
            let venueList = coffeeListTableViewController.extractVenueListFromData(json)
            for venue in venueList{
                XCTAssertNotNil(venue, "venue is nil")
                XCTAssertTrue(venue.isKindOfClass(Venue), "venue is not a kind of Venue")
            }
        }else{
            XCTFail("Mock Json file not read")
        }
    }
    
    func testGetVenueInfoFromServer(){
        if let url = coffeeDetailTableViewController.venueUrl(mockVenueId){
            let urlRequest = NSURLRequest(URL: url)
            let expectation = expectationWithDescription("Get json for venue API with url: \(url)")
            NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler:{urlResponse, data, error in
                expectation.fulfill()
                
                XCTAssertNotNil(data, "data should not be nil")
                XCTAssertNil(error, "error should be nil")
                
                if let response = urlResponse as? NSHTTPURLResponse {
                    XCTAssertEqual(response.statusCode, 200, "HTTP response status code should be 200")
                    XCTAssertEqual(response.MIMEType!, "application/json", "HTTP response content type should be application/json")
                } else {
                    XCTFail("Response was not NSHTTPURLResponse")
                }
                
                var error: NSError?
                let jsonDict: NSDictionary? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as? NSDictionary
                XCTAssertNotNil(jsonDict, "\(__FUNCTION__): JSONObjectWithData error: \(error)")
            })
            
            waitForExpectationsWithTimeout(60, handler: { error in
            })
        }else{
            XCTFail("Venue URL fail to create")
        }
    }
    
}
