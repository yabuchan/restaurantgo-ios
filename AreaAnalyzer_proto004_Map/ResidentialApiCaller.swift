//
//  ResidentialApiCaller.swift
//  AreaAnalyzer_proto004_Map
//
//  Created by yabu on 2015/11/22.
//  Copyright © 2015年 ybsk. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ResidentialApiCaller: NSObject {
    let latitude = 35.702941
    let longtitude = 139.665283
    var dataNsstring: NSString = ""

    func getHeatmapDataFromHomesApi(heatmapData: heatmapDataController){
        let homesUrl = "http://homes-archive-rest.herokuapp.com/api/1.0"
    
        Alamofire.request(.GET, homesUrl, parameters: ["latitude":latitude, "longitude":longtitude, "radius":0.01, "class":"nonResidential"])
            .response { (request, response, data, error) in
                
                self.dataNsstring = NSString(data:data!, encoding:NSUTF8StringEncoding)!
            
                if let dataFromString = self.dataNsstring.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false){
                    let jsonData2 = JSON(data: dataFromString)
                

                    let numberOfShop: Int = jsonData2["results"]["raw"].count
                    print("homes response num:", numberOfShop)
                
                    for (var i = 0; i < numberOfShop; i++) {
                        let lat: Double = jsonData2["results"]["raw"][i]["coordinate"]["lat"].double!
                        let lng: Double = jsonData2["results"]["raw"][i]["coordinate"]["lng"].double!

                        heatmapData.appendData(lat, lng:lng, weight:1)
                    }
                }
                heatmapData.setHeatmapData(heatmapData.weight, lat:heatmapData.lat, lng:heatmapData.lng)
        }
    }
}
