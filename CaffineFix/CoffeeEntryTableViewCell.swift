//
//  CoffeeEntryTableViewCell.swift
//  CaffineFix
//
//  Created by Victor Chan on 31/1/15.
//  Copyright (c) 2015 Spark Plug Studio. All rights reserved.
//

import UIKit

class CoffeeEntryTableViewCell: UITableViewCell {

    @IBOutlet weak var shopImage:UIImageView!
    @IBOutlet weak var shopNameLabel:UILabel!
    @IBOutlet weak var shopAddressLabel:UILabel!
    @IBOutlet weak var shopPriceLabel:UILabel!
    @IBOutlet weak var distanceLabel:UILabel!
    @IBOutlet weak var openingStatusLabel: UILabel!
    
    let thumbnailRes:NSInteger = 100
    var venue: NSDictionary = NSDictionary(){
        didSet{
            //Set shop name
            
            if let shopName = venue.objectForKey("name") as? String{
                shopNameLabel.text = shopName
            }
            
            let location: NSDictionary = venue.objectForKey("location") as NSDictionary
            
            //Set shop address
            
            if let address = location.objectForKey("address") as? String{
                shopAddressLabel.text="\(address)"
            }
            
            if let crossStreet = location.objectForKey("crossStreet") as? String{
                if countElements(shopAddressLabel.text!)==0{
                    shopAddressLabel.text = crossStreet
                }else{
                    shopAddressLabel.text = "\(shopAddressLabel.text!) \n(\(crossStreet))"
                }
            }
            
            if let city = location.objectForKey("city") as? String{
                if countElements(shopAddressLabel.text!)==0{
                    shopAddressLabel.text = city
                }else{
                    shopAddressLabel.text = "\(shopAddressLabel.text!) \n\(city)"
                }
            }
            
            if let state = location.objectForKey("state") as? String{
                if countElements(shopAddressLabel.text!)==0{
                    shopAddressLabel.text = state
                }else{
                    shopAddressLabel.text = "\(shopAddressLabel.text!) \(state)"
                }
            }
            
            //Set shop distance
            if let distance = location.objectForKey("distance") as? Int{
                if distance>=1000{
                    distanceLabel.text = String(format: "%.02f km",round(Float(distance)/50.0)/20)
                }else{
                    distanceLabel.text = String(format:"%d m",Int(round(Float(distance)/50.0)*50))
                }
                
            }
            
            //Set Price
            let priceRatingDict = venue.objectForKey("price") as NSDictionary?
            
            if let priceRating = priceRatingDict?.objectForKey("tier") as Int?{
                shopPriceLabel.attributedText=NSAttributedString(string: "$$$$", attributes: [NSForegroundColorAttributeName:UIColor.grayColor(),NSFontAttributeName:UIFont.systemFontOfSize(shopPriceLabel.font.pointSize)])
                let priceString = NSMutableAttributedString(attributedString: shopPriceLabel.attributedText)
                priceString.setAttributes([NSForegroundColorAttributeName:UIColor.blackColor(),NSFontAttributeName:UIFont.boldSystemFontOfSize(shopPriceLabel.font.pointSize)], range: NSMakeRange(0, priceRating))
                shopPriceLabel.attributedText = priceString
            }else{
                shopPriceLabel.attributedText=NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName:UIColor.grayColor(),NSFontAttributeName:UIFont.systemFontOfSize(shopPriceLabel.font.pointSize)])
            }
            
            //Set opening hours
            
            let openingHoursDict = venue.objectForKey("hours") as NSDictionary?
            if let openingHours = openingHoursDict?.objectForKey("status") as String? {
                //Has status
                openingStatusLabel.text = openingHours
                
                if let isOpen = openingHoursDict?.objectForKey("isOpen") as Bool?{
                    //Know if its open or not
                    if isOpen{
                        openingStatusLabel.textColor = UIColor.greenColor()
                    }else{
                        openingStatusLabel.textColor = UIColor.redColor()
                    }
                }else{
                    //Don't know if open
                    openingStatusLabel.textColor=UIColor.blackColor()
                }
            }else{
                //Does not have status
            }
            
            //Set Image
            
            if let photo = venue.objectForKey("featuredPhotos") as NSDictionary? {
                //Has Photo
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)){
                    //Getting image in background
                    //Construct URL to get the image
                    let itemsArray = photo.objectForKey("items") as NSArray?
                    let itemsDict = itemsArray?.firstObject as NSDictionary?
                    let photoUrlPrefix = itemsDict?.objectForKey("prefix") as String
                    let photoUrlSuffix = itemsDict?.objectForKey("suffix") as String
                    let photoRes = "\(self.thumbnailRes)x\(self.thumbnailRes)"
                    var urlString = "\(photoUrlPrefix)\(photoRes)\(photoUrlSuffix)"
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible=true
                    let image: UIImage? = UIImage(data: NSData(contentsOfURL: NSURL(string: urlString)!)!)
                    UIApplication.sharedApplication().networkActivityIndicatorVisible=false
                    
                    dispatch_async(dispatch_get_main_queue()){
                        self.shopImage.image = image
                    }
                }
            }else{
                //No Photo
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        shopNameLabel.text=""
        shopAddressLabel.text=""
        openingStatusLabel.text=""
        self.shopImage.image = UIImage(named: "PlaceholderImage")
        shopImage.layer.masksToBounds=true
        shopImage.layer.cornerRadius = 5.0
    }

}
