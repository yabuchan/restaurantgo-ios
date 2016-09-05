//
//  yelpApiContents.swift
//  AreaAnalyzer_proto004_Map
//
//  Created by Hitoshi Yabusaki on 2015/10/25.
//  Copyright © 2015年 ybsk. All rights reserved.
//

import UIKit

class BusinessOverview: NSObject {
    let total: Int?
    
    init(dictionary: NSDictionary) {
        total = dictionary["total"] as? Int
    }
    
    class func total(dictionary: NSDictionary) -> Int {
        let total = dictionary["total"] as! Int
        return total
    }
    
    class func searchWithTerm(term: String, completion: ([Business]!, NSError!) -> Void) {
        YelpClient.sharedInstance.searchWithTerm(term, completion: completion)
    }
    
    class func getTotalBusinessNum(term: String, lat: Double, lng: Double, radius: Int, sort: YelpSortMode?, categories: [String]?, deals: Bool?, completion: (Int, NSError!) -> Void) -> Void {
        YelpClient.sharedInstance.getTotalBusinessNum(term, lat: lat, lng: lng, radius: radius, sort: sort, categories: categories, deals: deals, completion: completion)
    }
}