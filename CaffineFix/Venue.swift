//
//  Venue.swift
//  CaffineFix
//
//  Created by Victor Chan on 1/2/15.
//  Copyright (c) 2015 Spark Plug Studio. All rights reserved.
//

import Foundation

class Venue {
    var shopId: String = ""
    var shopName: String = ""
    var address: String = ""
    var distance: Int = 0
    var priceRating: Int = 0
    var isOpen: Bool = false
    var openStatus: String = ""
    var photoPrefix: String = ""
    var photoSuffix: String = ""
    var hasPhoto: Bool = false
    var venueDict:NSDictionary?
    
    init(venue: NSDictionary){
        venueDict = venue
        
        if let venueId = venue.objectForKey("id") as? String{
            shopId = venueId
        }
        if let shopNameString = venue.objectForKey("name") as? String{
            shopName = shopNameString
        }
        
        let location: NSDictionary = venue.objectForKey("location") as NSDictionary
        
        //Set shop address
        
        if let addressString = location.objectForKey("address") as? String{
            address = "\(addressString)"
        }
        
        if let crossStreet = location.objectForKey("crossStreet") as? String{
            if countElements(address)==0{
                address = crossStreet
            }else{
                address = "\(address) \n(\(crossStreet))"
            }
        }
        
        if let city = location.objectForKey("city") as? String{
            if countElements(address)==0{
                address = city
            }else{
                address = "\(address) \n\(city)"
            }
        }
        
        if let state = location.objectForKey("state") as? String{
            if countElements(address)==0{
                address = state
            }else{
                address = "\(address) \(state)"
            }
        }
        
        //Set shop distance
        if let distanceInt = location.objectForKey("distance") as? Int{
            distance = distanceInt
        }
        
        //Set Price
        let priceRatingDict = venue.objectForKey("price") as NSDictionary?
        
        if let priceRatingInt = priceRatingDict?.objectForKey("tier") as Int?{
            priceRating = priceRatingInt
        }
        
        //Set opening hours
        
        let openingHoursDict = venue.objectForKey("hours") as NSDictionary?
        if let openingHours = openingHoursDict?.objectForKey("status") as String? {
            //Has status
            openStatus = openingHours
            
            if let isOpenBool = openingHoursDict?.objectForKey("isOpen") as Bool?{
                //Know if its open or not
                isOpen = isOpenBool
            }
        }else{
        }
        
        //Set Photo URL and has photo
        
        if let photo = venue.objectForKey("featuredPhotos") as NSDictionary? {
            //Has Photo
            if let itemsArray = photo.objectForKey("items") as NSArray?{
                let itemsDict = itemsArray.firstObject as NSDictionary?
                if let photoUrlPrefix = itemsDict?.objectForKey("prefix") as? String{
                    if let photoUrlSuffix = itemsDict?.objectForKey("suffix") as? String{
                        photoPrefix = photoUrlPrefix
                        photoSuffix = photoUrlSuffix
                        hasPhoto = true
                    }
                }
            }
        }
    }
}