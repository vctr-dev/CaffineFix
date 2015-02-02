//
//  CoffeeDetailTableViewController.swift
//  CaffineFix
//
//  Created by Victor Chan on 1/2/15.
//  Copyright (c) 2015 Spark Plug Studio. All rights reserved.
//

import UIKit
import CoreLocation

class CoffeeDetailTableViewController: UITableViewController {

    @IBOutlet weak var featuredImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var callCell: UITableViewCell!
    
    var venue:Venue?
    var coordinates:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var res = "500x300"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        featuredImage.clipsToBounds = true

        callCell.hidden = true
        if let venueItem = venue{
            //Set Name
            self.navigationItem.title=venueItem.shopName
            
            //Set address
            addressLabel.text = venueItem.address.stringByReplacingOccurrencesOfString("\n", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            //Set lat long
            if let location = venueItem.venueDict!.objectForKey("location") as NSDictionary?{
                coordinates.latitude = location.objectForKey("lat") as CLLocationDegrees
                coordinates.longitude = location.objectForKey("lng") as CLLocationDegrees
            }
            
            //Get image
            if venueItem.hasPhoto{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)) {
                    let img = UIImage(data: NSData(contentsOfURL: NSURL(string: "\(venueItem.photoPrefix)\(self.res)\(venueItem.photoSuffix)")!)!)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.featuredImage.image = img
                    }
                }
            }
            
            //Get contact info request
            self.getVenueDetail(venueItem)
        }
    }
    
    func venueUrl(shopid:String)->NSURL?{
        var urlString = "\(venueAPI)\(shopid)?client_id=\(clientId)&client_secret=\(clientSecret)&v=\(version)&m=\(method)"
        return NSURL(string: urlString)
    }
    
    func venueUrlRequest(shopid:String)->NSURLRequest{
        
        return NSURLRequest(URL: venueUrl(shopid)!)
    }
    
    func getVenueDetail(venueItem: Venue){
        let urlRequest = venueUrlRequest(venueItem.shopId)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible=true
        // Send url request on async
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler:{urlResponse, data, error in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible=false
            
            // If error, print error and escape
            if urlResponse.isKindOfClass(NSHTTPURLResponse){
                let statusCode = (urlResponse as NSHTTPURLResponse).statusCode
                if statusCode != 200{
                    println("\(__FUNCTION__): sendAsynchronousRequest status code != 200: response = \(urlResponse)")
                    return
                }
            }
            
            
                self.extractPhoneNumberFromData(data)
        })
    }
    func extractPhoneNumberFromData(data:NSData){
        var error: NSError?
        let jsonDict: NSDictionary? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as? NSDictionary
        if let dict = jsonDict{
            if let venueItem = venue{
                venueItem.venueDetailDict = dict
                if venueItem.hasPhoneNumber{
                    self.callCell.hidden = false
                    if venueItem.formattedNumber==""{
                        phoneNumberLabel.text = venueItem.phoneNumber
                    }else{
                        phoneNumberLabel.text = venueItem.formattedNumber
                    }
                }
            }
        }else{
            //if jsonDict is nil means parsing has failed.
            println("\(__FUNCTION__): JSONObjectWithData error: \(error)")
        }
    }
    
    //Set image
    
    //Set contact info
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return (indexPath.section == 2)
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 2{
            switch(indexPath.row){
            case 0:
                //Get direction
                UIApplication.sharedApplication().openURL(NSURL(string:"http://maps.apple.com/?q=\(coordinates.latitude),\(coordinates.longitude)")!)
                return
            case 1:
                if let venueItem = venue{
                    if venueItem.hasPhoneNumber{
                        UIApplication.sharedApplication().openURL(NSURL(string: "tel:\(venueItem.phoneNumber)")!)
                    }
                }
                return
            default:
                return
            }
        }
    }
}
