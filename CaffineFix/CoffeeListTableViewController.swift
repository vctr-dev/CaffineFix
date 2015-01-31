//
//  CoffeeListTableViewController.swift
//  CaffineFix
//
//  Created by Victor Chan on 31/1/15.
//  Copyright (c) 2015 Spark Plug Studio. All rights reserved.
//

import UIKit

class CoffeeListTableViewController: UITableViewController {
    let testLL = "-35.236944,149.068889"//TODO Remove when launch
    let exploreSection = "coffee"
    let venuePhotos = 1
    let sortByDistance = 1
    let openNow = 0
//    let resultLimit = Int.max
    var venueList:NSArray = NSArray()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        
        self.refreshControl?.beginRefreshing()
        self.refresh()
        
    }
    
    func refresh(){
        self.getLocation()
    }
    
    func getLocation(){
        
        self.didReceiveLocation()//Proxy stud
    }
    
    func didReceiveLocation(){
        self.getDataFromServer(testLL)
    }

    // MARK: - Table view data source
    
    func getDataFromServer(latLong:String){
        
        // Creating URL request
        var urlString = "https://api.foursquare.com/v2/venues/explore?client_id=\(clientId)&client_secret=\(clientSecret)&v=\(version)&m=\(method)&ll=\(latLong)&section=\(exploreSection)&venuePhotos=\(venuePhotos)&sortByDistance=\(sortByDistance)&openNow=\(openNow)"
        var url = NSURL(string: urlString)
        var urlRequest = NSURLRequest(URL: url!)
        
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
                self.extractVenueListFromDict(dict, latLong: latLong)
            }else{
                //if jsonDict is nil means parsing has failed.
                println("\(__FUNCTION__): JSONObjectWithData error: \(error)")
                return
            }
        })
    }
    
    func extractVenueListFromDict(dict:NSDictionary, latLong:String){
        let responseDict = dict.objectForKey("response")! as NSDictionary
        let groupsArray = responseDict.objectForKey("groups")! as NSArray
        let groupsDict = groupsArray.firstObject as NSDictionary
        let resultList = groupsDict.objectForKey("items")! as NSArray
        
        //Extracting out the venues array from the list and put into new array
        venueList = NSArray()
        for result in resultList{
            venueList = venueList.arrayByAddingObject(result.objectForKey("venue")!)
        }
        self.tableView.reloadData()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        if venueList.count == 0{
            
            // Display a message when the table is empty
            let messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            
            if let refresher = self.refreshControl?{
                if refresher.refreshing{
                    messageLabel.text = "Refreshing..."
                }else{
                    messageLabel.text = "No data is currently available. Please pull down to refresh."
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
        cell.venue = venueList.objectAtIndex(indexPath.row) as NSDictionary
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    

}
