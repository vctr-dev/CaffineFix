//
//  CoffeeListTableViewController.swift
//  CaffineFix
//
//  Created by Victor Chan on 31/1/15.
//  Copyright (c) 2015 Spark Plug Studio. All rights reserved.
//

import UIKit
import CoreLocation

class CoffeeListTableViewController: UITableViewController,CLLocationManagerDelegate {
    let testLL = "-35.236944,149.068889"//TODO Remove when launch
    let exploreSection = "coffee"
    let venuePhotos = 1
    let sortByDistance = 1
    let openNow = 0
    //    let resultLimit = Int.max
    var venueList:NSArray = NSArray()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Let the back button title be empty to maximize the space on navigation bar on any pushed view controller
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        //Flexible row height so that cell contents can be displayed correclt. AutoLayout constraints for cell's bottom margin are in place, relative to the items at the bottom of the row.
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //Workaround as table cell height auto-layout is buggy when segue from cell
        tableView.estimatedRowHeight = 88
        
        locationManager.delegate=self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        //Required for using location within app. Updated for iOS 8. Message to be displayed in info.plist
        if locationManager.respondsToSelector("requestWhenInUseAuthorization"){
            locationManager.requestWhenInUseAuthorization()
        }
        
        //Pull to refresh control
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        
        refreshControl?.beginRefreshing()
        refresh()
    }
    
    func refresh(){
        // Updates every 500m (good when going to new location)
        locationManager.distanceFilter = 500
        
        //Gets the current location and send the current location to delegate
        locationManager.stopUpdatingLocation()
        locationManager.startUpdatingLocation()
    }
    
    
    // MARK: - Location manager delegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        //Handles location retrieved by location manager
        if let location = locations.last as CLLocation?{
            let coordinate = location.coordinate
            getDataFromServer("\(coordinate.latitude),\(coordinate.longitude)")
        }else{
            refreshControl?.endRefreshing()
            tableView.reloadData()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("\(__FUNCTION__): \(error)")
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    
    //MARK: - Server Communication
    func exploreUrl(latLong:String) -> NSURL?{
        var urlString = "\(exploreAPI)?client_id=\(clientId)&client_secret=\(clientSecret)&v=\(version)&m=\(method)&ll=\(latLong)&section=\(exploreSection)&venuePhotos=\(venuePhotos)&sortByDistance=\(sortByDistance)&openNow=\(openNow)"
        return NSURL(string: urlString)
    }
    
    func getDataFromServer(latLong:String){
        //Async getting data from server
        let session = NSURLSession.sharedSession()
        UIApplication.sharedApplication().networkActivityIndicatorVisible=true
        
        session.dataTaskWithURL(exploreUrl(latLong)!, completionHandler: { data, urlResponse, error in
            UIApplication.sharedApplication().networkActivityIndicatorVisible=false
            self.refreshControl?.endRefreshing()
            
            // If error, print error and escape
            if urlResponse.isKindOfClass(NSHTTPURLResponse){
                let statusCode = (urlResponse as NSHTTPURLResponse).statusCode
                if statusCode != 200{
                    println("\(__FUNCTION__): dataTaskWithURL status code != 200: response = \(urlResponse)")
                    return
                }
            }
            self.extractVenueListFromData(data)
        }).resume()
    }
    
    func extractVenueListFromData(data:NSData) -> NSArray{
        var error: NSError?
        let jsonDict: NSDictionary? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as? NSDictionary
        if let dict = jsonDict{
            //Venue items are in response -> groups -> items
            let responseDict = dict.objectForKey("response")! as NSDictionary
            let groupsArray = responseDict.objectForKey("groups")! as NSArray
            let groupsDict = groupsArray.firstObject as NSDictionary
            let resultList = groupsDict.objectForKey("items")! as NSArray
            
            //Extracting out the venues array from the list and put into new array
            venueList = NSArray()
            for result in resultList{
                venueList = venueList.arrayByAddingObject(Venue(venue:result.objectForKey("venue") as NSDictionary))
            }
            tableView.reloadData()
            return venueList
            
        }else{
            //if jsonDict is nil means parsing has failed.
            println("\(__FUNCTION__): JSONObjectWithData error: \(error)")
            return NSArray()
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        if venueList.count == 0{
            
            // Display a message when the table is empty
            let messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            
            if let refresher = self.refreshControl?{
                if refresher.refreshing{
                    messageLabel.text = "Brewing..."
                }else{
                    messageLabel.text = "No data retrieved.\nPull down to try again."
                }
            }
            
            messageLabel.textColor = UIColor.blackColor()
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = NSTextAlignment.Center
            messageLabel.font = UIFont(name: "Palatino-Italic", size: 20)
            messageLabel.sizeToFit()
            
            tableView.backgroundView = messageLabel;
            tableView.separatorStyle = .None
            return 0
            
        }else{
            tableView.separatorStyle = .SingleLine
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return venueList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as CoffeeEntryTableViewCell
        if let venueItem = venueList.objectAtIndex(indexPath.row) as? Venue{
            cell.venue = venueItem
        }
        return cell
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //Pass the right venue to the destination view controller
        let destVC = segue.destinationViewController as CoffeeDetailTableViewController
        let selectedCellIndexPath = tableView.indexPathForSelectedRow()
        let selectedCell = tableView.cellForRowAtIndexPath(selectedCellIndexPath!) as CoffeeEntryTableViewCell
        destVC.venue = selectedCell.venue
        self.tableView.deselectRowAtIndexPath(selectedCellIndexPath!, animated: true)
    }
    
}
