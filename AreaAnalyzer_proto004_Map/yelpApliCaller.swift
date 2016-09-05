//
//  yelpApliCaller.swift
//  AreaAnalyzer_proto004_Map
//
//  Created by Hitoshi Yabusaki on 2015/10/25.
//  Copyright © 2015年 ybsk. All rights reserved.

import Foundation
import BDBOAuth1Manager
import AFNetworking
//import NSDictionary+BDBOAuth1Manager
//import UIImageView+AFNetworking
// You can check Yelp API keys here: http://www.yelp.com/developers/manage_api_keys

let yelpConsumerKey = "b5SjotyfvEw7jstCEMM21Q"
let yelpConsumerSecret = "v4Bcji-Dmb17RdzBMURFJkEXco8"
let yelpToken = "Kyh-5jgrbjBe2SRVD2Ytd_TNlCdHm0kn"
let yelpTokenSecret = "bzNIkf6AH_dE7SOHT1dbDQyC7do"

enum YelpSortMode: Int {
    case BestMatched = 0, Distance, HighestRated
}


class YelpClient: BDBOAuth1RequestOperationManager {
    var accessToken: String!
    var accessSecret: String!
    
    class var sharedInstance : YelpClient {
        struct Static {
            static var token : dispatch_once_t = 0
            static var instance : YelpClient? = nil
        }
        
        dispatch_once(&Static.token) {
        Static.instance = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        }
        return Static.instance!
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(consumerKey key: String!, consumerSecret secret: String!, accessToken: String!, accessSecret: String!) {
        self.accessToken = accessToken
        self.accessSecret = accessSecret
        let baseUrl = NSURL(string: "https://api.yelp.com/v2/")
        super.init(baseURL: baseUrl, consumerKey: key, consumerSecret: secret);
        
        let token = BDBOAuth1Credential(token: accessToken, secret: accessSecret, expiration: nil)
        self.requestSerializer.saveAccessToken(token)
    }
    
    func searchWithTerm(term: String, completion: ([Business]!, NSError!) -> Void) -> AFHTTPRequestOperation {
        return searchWithTerm(term, sort: nil, categories: nil, deals: nil, completion: completion)
    }
    
    func searchWithTerm(term: String, sort: YelpSortMode?, categories: [String]?, deals: Bool?, completion: ([Business]!, NSError!) -> Void) -> AFHTTPRequestOperation {
        // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api
        // Default the location to San Francisco
        var parameters: [String : AnyObject] = ["term": term, "ll": "37.785771,-122.406165"]
        
        if sort != nil {
            parameters["sort"] = sort!.rawValue
        }
        
        if categories != nil && categories!.count > 0 {
            parameters["category_filter"] = (categories!).joinWithSeparator(",")
        }
        
        if deals != nil {
            parameters["deals_filter"] = deals!
        }

//        print("parameter:", parameters)

        return self.GET("search", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            let dictionaries = response["businesses"] as? [NSDictionary]
            if dictionaries != nil {
                completion(Business.businesses(array: dictionaries!), nil)
            }
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                print("error:", error, "****************")
                completion(nil, error)

        })!
    }

    
    
    //_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
    //Original one. if you wanna change, it is better to change this func rather than upper func.
    func searchWithTerm(term: String, lat: Double, lng: Double, sort: YelpSortMode?, categories: [String]?, deals: Bool?, page_index:Int, limit: Int, completion: ([Business]!, NSError!) -> Void) -> AFHTTPRequestOperation {
        // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api
        
        // Default the location to Tokyo
        var parameters: [String : AnyObject] = ["term": term, "ll": "\(lat),\(lng)"]
//        var parameters: [String : AnyObject] = ["term": "food", "location": "Chicago"]
        if sort != nil {
            parameters["sort"] = sort!.rawValue
        }
        
        if categories != nil && categories!.count > 0 {
            parameters["category_filter"] = (categories!).joinWithSeparator(",")
        }
        
        if deals != nil {
            parameters["deals_filter"] = deals!
        }

        parameters["limit"] = limit // 20 is the upper limit defined by Yelp.
        parameters["offset"] = page_index * limit

        
        print("parameter:", parameters)
        
        return self.GET("search", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            let dictionaries = response["businesses"] as? [NSDictionary]
            if dictionaries != nil {
                completion(Business.businesses(array: dictionaries!), nil)
            }
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                print("error:", error, "****************")
                completion(nil, error)
                
        })!
    }
    
    func getTotalBusinessNum(term: String, lat: Double, lng: Double, radius: Int, sort: YelpSortMode?, categories: [String]?, deals: Bool?, completion: (Int, NSError!) -> Void) -> AFHTTPRequestOperation {
        // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api
        
         // Default the location to Tokyo
        var parameters: [String : AnyObject] = ["term": term, "ll": "\(lat),\(lng)"]
        
       if sort != nil {
            parameters["sort"] = sort!.rawValue
        }

        if categories != nil && categories!.count > 0 {
            parameters["category_filter"] = (categories!).joinWithSeparator(",")
        }

        if deals != nil {
            parameters["deals_filter"] = deals!
        }

        parameters["cc"] = "JP"
//        parameters["radius_filter"] = radius

        print("parameter:", parameters)
        
        return self.GET("search", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
//            print(response)
            let total = response["total"] as? Int
            if total != nil {
                completion(total!, nil)
            }
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                print("error:", error, "****************")
                completion(-1, error)
                
        })!
    }
/*
    func getAllBusiness(term: String, lat: Double, lng: Double, radius: Int, sort: YelpSortMode?, categories: [String]?, deals: Bool?, completion: (Int, NSError!) -> Void) -> AFHTTPRequestOperation {
        // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api
        
        var i:Int = 0
        var shopList:Dictionary = Dictionary()
        
        // Default the location to Tokyo
        var parameters: [String : AnyObject] = ["term": term, "ll": "\(lat),\(lng)"]
        
        if sort != nil {
            parameters["sort"] = sort!.rawValue
        }
        
        if categories != nil && categories!.count > 0 {
            parameters["category_filter"] = (categories!).joinWithSeparator(",")
        }
        
        if deals != nil {
            parameters["deals_filter"] = deals!
        }
        
        parameters["cc"] = "JP"
        //        parameters["radius_filter"] = radius
        
        print("parameter:", parameters)
        
        return self.GET("search", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            //            print(response)
            let total = response["total"] as? Int
            if total != nil {
                
                
                var page_index = 0
                repeat {
                    
                    print("before page: ", page_index)
                    Business.searchWithTerm(term, lat: lat, lng: lng, sort: sort, categories: categories, deals: deals, page_index: page_index, limit: 20) {
                        (businesses: [Business]!, error: NSError!) -> Void in
                        
                        //                print(businesses)
                        
                        if(businesses != nil){
                            let responseNum = businesses.count
                            for business in businesses {
//                                shopList.append(
                                print(i++,", name:", business.name!, "lat:", business.latitude!, " lng:", business.longtitude!)
                                //                    print("address:", business.address!)
                                //                    print("lat:", business.latitude!, " lng:", business.longtitude!)
                            }
                            
                        }else{
                            print("no response")
                        }
                    }
                    page_index++
                } while page_index < 3 //responseNum == limit
                
                
                
                completion(total!, nil)
            }
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                print("error:", error, "****************")
                completion(-1, error)
                
        })!
    }
*/
}