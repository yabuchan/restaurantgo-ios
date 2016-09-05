//
//  heatmapDataController.swift
//  AreaAnalyzer_proto004_Map
//
//  Created by yabu on 2015/11/22.
//  Copyright © 2015年 ybsk. All rights reserved.
//

import Foundation
import DTMHeatmap

class heatmapDataController: NSObject{
    var  lat: [Double] = [Double]()
    var  lng: [Double] = [Double]()
    var  weight: [Double] = [Double]()
    let heatmap: DTMHeatmap = DTMHeatmap()

    override init(){
        print("init called @heatmapDataController")
    }
    
    func appendData(lat: Double, lng: Double, weight: Double){
        self.lat.append(lat)
        self.lng.append(lng)
        self.weight.append(1)
    }
    
    func setHeatmapData(weight:[Double], lat:[Double], lng:[Double]){
        let heatmapConvertedData = self.heatmap.convertHeatmapDataOfWeight(self.weight, heatmapLatitude: self.lat, heatmapLongtitude: self.lng, dataNum: Int32(self.lat.count))
        
        self.heatmap.setData(heatmapConvertedData)
    }
}