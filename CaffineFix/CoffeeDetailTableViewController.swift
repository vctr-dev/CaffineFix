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
    var res = "500x300" //Photo resolution of the featured photo to display
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Else the image view may be displayed out of the table cell view
        featuredImage.clipsToBounds = true
        
        //Call cell is hidden until the phone number is found
        callCell.hidden = true
        if let venueItem = venue{
            //Set Name
            navigationItem.title=venueItem.shopName
            
            //Set address
            addressLabel.text = venueItem.address.stringByReplacingOccurrencesOfString("\n", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
           
            //Get image
            switch venueItem.photo{
            case .Present(let photoPrefix, let photoSuffix):
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)){
                    //Getting image in background
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                    let img = UIImage(data: NSData(contentsOfURL: NSURL(string: "\(photoPrefix)\(self.res)\(photoSuffix)")!)!)
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    
                    dispatch_async(dispatch_get_main_queue()){
                        self.featuredImage.image = img
                    }
                }
            default:
                break
            }
            
            //Get contact info request
            getVenueDetail(venueItem)
        }
    }
    
    func venueUrl(shopid:String)->NSURL?{
        var urlString = "\(venueAPI)\(shopid)?client_id=\(clientId)&client_secret=\(clientSecret)&v=\(version)&m=\(method)"
        return NSURL(string: urlString)
    }
    
    //Get the contact details (if any) from server
    func getVenueDetail(venueItem: Venue){
        
        let session = NSURLSession.sharedSession()
        UIApplication.sharedApplication().networkActivityIndicatorVisible=true
        
        // Send url request on async
        session.dataTaskWithURL(venueUrl(venueItem.shopId)!, completionHandler: {data, urlResponse, error in
            UIApplication.sharedApplication().networkActivityIndicatorVisible=false
            
            // If error, print error and escape
            if urlResponse.isKindOfClass(NSHTTPURLResponse){
                let statusCode = (urlResponse as NSHTTPURLResponse).statusCode
                if statusCode != 200{
                    println("\(__FUNCTION__): dataTaskWithURL status code != 200: response = \(urlResponse)")
                    return
                }
            }
            self.extractPhoneNumberFromData(data)
        }).resume()
    }
    
    func extractPhoneNumberFromData(data:NSData){
        var error: NSError?
        let jsonDict: NSDictionary? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as? NSDictionary
        if let dict = jsonDict{
            if let venueItem = venue{
                venueItem.venueDetailDict = dict
                if venueItem.hasPhoneNumber{
                    callCell.hidden = false
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
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        //Only highlight actionable cells (in section 2)
        return (indexPath.section == 2)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 2{
            switch(indexPath.row){
            case 0:
                //Open the location in maps
                if let venueItem = venue{
                    UIApplication.sharedApplication().openURL(NSURL(string:"http://maps.apple.com/?q=\(venueItem.coordinates.latitude),\(venueItem.coordinates.longitude)")!)
                }
                return
            case 1:
                //Make a call if there is a phone number
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
