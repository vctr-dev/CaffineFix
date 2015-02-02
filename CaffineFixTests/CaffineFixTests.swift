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
    let testLL = "37.33240905,-122.03051211"
    // Can create 
    let shopidWithPic = "4bf58dd8d48988d1e0931735"
    let shopidWithoutPic = "4f4eb369e4b0e52480690902"
    let shopidWithContact = "4e4dd3f8bd41b76bef93cbf0"
    let shopidWithoutContact = "4dd1a2d652b15d0acc6c89dd"
    
    let coffeeListTableViewController = CoffeeListTableViewController()
    
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
    }
    
    func testGettingVenuesFromServer(){
        XCTAssertNotNil(coffeeListTableViewController.exploreUrl(testLL), "Explore URL fail to create")
        
    }
    
    func testExtractingVenuesFromJson(){
        //Using mock json, test if venue can be extracted properly using extractVenue function
    }
    
    func testDisplayVenueInCoffeeEntryTableViewCell(){
        //Using mock venues, test if cells display correctly
    }
    
    func testGetVenueInfoFromServer(){
        //test if url is created correctly
        //test if venue is retrieved from server
    }
    
    func testExtractContactDetailsFromJson(){
        //using mock json, test if retrieve contact details
    }
    
    func testDisplayVenueDetailInCoffeeDetailTableViewController(){
        //Using mock venues, test if venues are displayed correctly.
    }
}
