//
//  CoffeeEntryTableViewCell.swift
//  CaffeineFix
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
    
    let closedStatusColor = UIColor.redColor()
    let openStatusColor = UIColor(red: 53.0/255.0, green: 193.0/255.0, blue: 0, alpha: 1)
    
    let thumbnailRes:NSInteger = 100
    var venue: Venue?{
        didSet{
            if let venueItem = venue{
                //Put the right details on the right labels
                shopNameLabel.text = venueItem.shopName
                shopAddressLabel.text=venueItem.address
                
                //Round the distance to 50 m for ease in user experience. if distance >= 1000 m, change the units to km
                let distance = Int(round(Float(venueItem.distance)/50.0)*50)
                if distance>=1000{
                    distanceLabel.text = String(format: "%.02f km",round(Float(distance)/50.0)/20)
                }else{
                    distanceLabel.text = String(format:"%d m",distance)
                }
                
                //Set the price rating to darken and bold the number of dollars according to the rating
                if venueItem.priceRating>0{
                    shopPriceLabel.attributedText=NSAttributedString(string: "$$$$", attributes: [NSForegroundColorAttributeName:UIColor.grayColor(),NSFontAttributeName:UIFont.systemFontOfSize(shopPriceLabel.font.pointSize)])
                    
                    let priceString = NSMutableAttributedString(attributedString: shopPriceLabel.attributedText)
                    priceString.setAttributes([NSForegroundColorAttributeName:UIColor.blackColor(),NSFontAttributeName:UIFont.boldSystemFontOfSize(shopPriceLabel.font.pointSize)], range: NSMakeRange(0, venueItem.priceRating))
                    
                    shopPriceLabel.attributedText = priceString
                }
                
                openingStatusLabel.text = venueItem.openStatus
                
                //Change the color of the opening status according to the status.
                if venueItem.isOpen{
                    openingStatusLabel.textColor = openStatusColor
                }else{
                    openingStatusLabel.textColor = closedStatusColor
                }
                
                //Get photo if photo is available
                switch venueItem.photo{
                case .Present(let photoPrefix, let photoSuffix):
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)){
                        //Getting image in background
                        //Construct URL to get the image
                        let shopId = venueItem.shopId
                        let photoRes = "\(self.thumbnailRes)x\(self.thumbnailRes)"
                        var urlString = "\(photoPrefix)\(photoRes)\(photoSuffix)"
                        UIApplication.sharedApplication().networkActivityIndicatorVisible=true
                        let image: UIImage? = UIImage(data: NSData(contentsOfURL: NSURL(string: urlString)!)!)
                        UIApplication.sharedApplication().networkActivityIndicatorVisible=false
                        
                        dispatch_async(dispatch_get_main_queue()){
                            if (self.venue != nil && self.venue!.shopId == shopId){
                                self.shopImage.image = image
                            }
                        }
                    }
                default:
                    break
                }
            }
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Set initial values of all labels and images
        shopNameLabel.text=""
        shopAddressLabel.text=""
        openingStatusLabel.text=""
        
        shopPriceLabel.attributedText=NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName:UIColor.grayColor(),NSFontAttributeName:UIFont.systemFontOfSize(shopPriceLabel.font.pointSize)])
        
        shopImage.image = UIImage(named: "PlaceholderImage")
        shopImage.layer.masksToBounds=true
        
        //circular photo frame
        shopImage.layer.cornerRadius=shopImage.bounds.size.height/2
        shopImage.layer.borderWidth=0
    }

}
