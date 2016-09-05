//
//  hotpepperApiCaller.swift
//  AreaAnalyzer_proto004_Map
//
//  Created by yabu on 2015/11/22.
//  Copyright © 2015年 ybsk. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class hotpepperApiCaller {
    
    //_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
    //MARK: get shops from hotpepper and update heatmap
    //(1) 座標を指定してショップ数を取得して、全ショップを取得するためにAPIを呼ぶ回数を計算する
    //(2) (1)のレスポンス受信後、APIを繰り返し呼び、お店の緯度・経度を取得する
    //(3) ヒートマップ更新する関数を呼ぶ
    func getShopsFromHotpepper(latitude: Double, longtitude: Double, heatmapData: heatmapDataController) {
        let hotpepperUrl = "http://webservice.recruit.co.jp/hotpepper/gourmet/v1/"
        let hotpepperKey = "5846c7a62ccbe280"
        let hotpepperRange = 1  //1: 300m, 2: 500m, 3: 1000m (初期値), 4: 2000m, 5: 3000m
        let hotpepperFormat = "json"
        let hotpepperNumberOfRequestShop = 100
        var dataNsstring: NSString = ""
        let hotpepperOrder = 4 //オススメ、距離順
        var hotpepperShopToStart:Int = 0
        var index: Int = 0
        var MaximumTimesToCallHotpepperApiForOneLocation = 0;
        var available_shops:Int = 0
        
print("hotpepperApiCaller!")
        
        Alamofire.request(.GET, hotpepperUrl, parameters: ["key": hotpepperKey, "lat":latitude, "lng":longtitude, "range":hotpepperRange, "count":0, "format":hotpepperFormat])
            .response { (request, response, data, error) in
                //  (1)データ数を取得する
                /*********
                self.updateHeatmap(request, response: response, data: data, error: error, numberOfRequestShop: hotpepperNumberOfRequestShop)
                **********/
                self.updateHeatmap(request, response: response, data: data, error: error, numberOfRequestShop: hotpepperNumberOfRequestShop, heatmapData:heatmapData)
                
                dataNsstring = NSString(data:data!, encoding:NSUTF8StringEncoding)!
                if let dataFromString = dataNsstring.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false){
                    let jsonData2 = JSON(data: dataFromString)
                    available_shops = jsonData2["results"]["results_available"].int!
                    MaximumTimesToCallHotpepperApiForOneLocation = (available_shops / hotpepperNumberOfRequestShop) + 1
                    
                    //    print("available shops:", available_shops, "ShopsInRequest:",hotpepperNumberOfRequestShop)
                    //    print("■■■ number: ", MaximumTimesToCallHotpepperApiForOneLocation)
                    
                    //(2) Repeat requests------------------
                    //例 http://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=5846c7a62ccbe280&lat=35.6817882691&lng=139.7667611654&range=5&format=json
                    for index in 0 ..< MaximumTimesToCallHotpepperApiForOneLocation{
                        Alamofire.request(.GET, hotpepperUrl, parameters: ["key": hotpepperKey, "lat":latitude, "lng":longtitude, "range":hotpepperRange, "count":hotpepperNumberOfRequestShop, "order": hotpepperOrder,"start":hotpepperShopToStart, "format":hotpepperFormat])
                            .response { (request, response, data, error) in
                                //(3) ヒートマップの更新
                                self.updateHeatmap(request, response: response, data: data, error: error, numberOfRequestShop: hotpepperNumberOfRequestShop, heatmapData: heatmapData)
                                
                        }
                        hotpepperShopToStart = index * hotpepperNumberOfRequestShop;
                    }
                    //---------------------------------
                }
        }
        
    }

    
    
    
    func updateHeatmap(request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, error: ErrorType?, numberOfRequestShop: Int, heatmapData: heatmapDataController){
        //        print(request)
        

        
        var dataNsstring: NSString = ""
        
        //                print("#### response:")
        //                print(response)
        
        dataNsstring = NSString(data:data!, encoding:NSUTF8StringEncoding)!
        
        if let dataFromString = dataNsstring.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false){
            let jsonData2 = JSON(data: dataFromString)
            
            let numberOfShop: Int = Int(jsonData2["results"]["results_returned"].string!)!
            for (var i = 0; i < numberOfShop; i++) {
                let lat: Double = atof(jsonData2["results"]["shop"][i]["lat"].string!)
                let lng: Double = atof(jsonData2["results"]["shop"][i]["lng"].string!)
                
                heatmapData.appendData(lat, lng:lng, weight:1)
//                print("lat:", lat, " lng:",lng)
            }
        }
        
        heatmapData.setHeatmapData(heatmapData.weight, lat:heatmapData.lat, lng:heatmapData.lng)
        
    }
 
}