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
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.locationManager.delegate=self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestWhenInUseAuthorization()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        
        self.refreshControl?.beginRefreshing()
        self.refresh()
        
    }

    //Workaround as table cell height auto-layout is buggy when segue from cell
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.tableView.reloadData()
    }
//    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    
    func refresh(){
        self.locationManager.distanceFilter = 500 // Updates every 500m (good when going to new location)
        self.locationManager.stopUpdatingLocation()
        self.locationManager.startUpdatingLocation()
    }
    
    
    // MARK: - Location manager delegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.last as CLLocation?{
            let coordinate = location.coordinate
            self.getDataFromServer("\(coordinate.latitude),\(coordinate.longitude)")
        }else{
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("\(__FUNCTION__): \(error)")
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }

    //MARK: - Server Communication
    func exploreUrl(latLong:String) -> NSURL?{
        var urlString = "\(exploreAPI)?client_id=\(clientId)&client_secret=\(clientSecret)&v=\(version)&m=\(method)&ll=\(latLong)&section=\(exploreSection)&venuePhotos=\(venuePhotos)&sortByDistance=\(sortByDistance)&openNow=\(openNow)"
        return NSURL(string: urlString)
    }
    
    func exploreUrlRequest(latLong:String) -> NSURLRequest{
        
        return NSURLRequest(URL: exploreUrl(latLong)!)
    }
    func getDataFromServer(latLong:String){
        
        // Creating URL request
        let urlRequest = exploreUrlRequest(latLong)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible=true
        // Send url request on async
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler:{urlResponse, data, error in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible=false
            self.refreshControl?.endRefreshing()
            
            // If error, print error and escape
            if urlResponse.isKindOfClass(NSHTTPURLResponse){
                let statusCode = (urlResponse as NSHTTPURLResponse).statusCode
                if statusCode != 200{
                    println("\(__FUNCTION__): sendAsynchronousRequest status code != 200: response = \(urlResponse)")
                    return
                }
            }
            
            var error: NSError?
            let jsonDict: NSDictionary? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as? NSDictionary
            if let dict = jsonDict{
                self.extractVenueListFromDict(dict)
            }else{
                //if jsonDict is nil means parsing has failed.
                println("\(__FUNCTION__): JSONObjectWithData error: \(error)")
                return
            }
        })
    }
    
    func extractVenueListFromDict(dict:NSDictionary) -> NSArray{
        let responseDict = dict.objectForKey("response")! as NSDictionary
        let groupsArray = responseDict.objectForKey("groups")! as NSArray
        let groupsDict = groupsArray.firstObject as NSDictionary
        let resultList = groupsDict.objectForKey("items")! as NSArray
        
        //Extracting out the venues array from the list and put into new array
        venueList = NSArray()
        for result in resultList{
            venueList = venueList.arrayByAddingObject(Venue(venue:result.objectForKey("venue") as NSDictionary))
        }
        self.tableView.reloadData()
        return venueList
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
            
            self.tableView.backgroundView = messageLabel;
            
            self.tableView.separatorStyle=UITableViewCellSeparatorStyle.None
            
            return 0
        }else{
            self.tableView.separatorStyle=UITableViewCellSeparatorStyle.SingleLine
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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        let destVC = segue.destinationViewController as CoffeeDetailTableViewController
        let selectedCellIndexPath = tableView.indexPathForSelectedRow()
        let selectedCell = tableView.cellForRowAtIndexPath(selectedCellIndexPath!) as CoffeeEntryTableViewCell
        destVC.venue = selectedCell.venue
        
    }

}
