//
//  ViewController.swift
//  AreaAnalyzer_proto004_Map
//
//  Created by Hitoshi Yabusaki on 2015/09/22.
//  Copyright (c) 2015年 ybsk. All rights reserved.
//

import UIKit
import MapKit
import DTMHeatmap
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!

    let heatmapData = heatmapDataController()
    let apiCaller = ResidentialApiCaller()
    let apiCallerHotpepper = hotpepperApiCaller()
    
    //yelp API
    var yelp_shop: [Business]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //MARK: Initialize map
        let initLatitude = 35.681382
        let initLongtitude = 139.766084
        let initialLocation: CLLocation
        let userLocation = MKUserLocation()
        print(userLocation.location)
        if userLocation.location == nil{
            initialLocation = CLLocation(latitude: initLatitude, longitude: initLongtitude)
        }else {
            initialLocation = userLocation.location!
        }
            centerMapOnLocation(initialLocation)
        
        //経路の計算
        var fromCoordinate :CLLocationCoordinate2D = CLLocationCoordinate2DMake(35.665213, 139.730011)
        var toCoordinate   :CLLocationCoordinate2D = CLLocationCoordinate2DMake(35.658987, 139.702776)
        
        var fromPlacemark = MKPlacemark(coordinate:fromCoordinate, addressDictionary:nil)
        var toPlacemark = MKPlacemark(coordinate:toCoordinate, addressDictionary:nil)
        
//        var fromItem = MKMapItem(placemark:fromPlacemark);
//        var toItem = MKMapItem(placemark:toPlacemark);
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark:fromPlacemark)
        request.destination = MKMapItem(placemark:toPlacemark)
        request.requestsAlternateRoutes = true; //複数経路
        request.transportType = MKDirectionsTransportType.Walking //移動手段 Walking:徒歩/Automobile:車

        
        let directions = MKDirections(request: request)
        directions.calculateDirectionsWithCompletionHandler
            {
                (response, error) -> Void in
                if let routes = response?.routes where response?.routes.count > 0 && error == nil
                {
                    let route : MKRoute = routes[0]
                    //distance calculated from the request
                    print(route.distance) 
                    //travel time calculated from the request
                    print(route.expectedTravelTime)
                    self.mapView.addOverlay(route.polyline)
                }
        }
        
        
        // ヒートマップの作成
//        self.getShopsFromHotpepper(initLatitude, longtitude: initLongtitude)

        
//        heatmap.setData(heatmap.convertHeatmapDataOfWeight(heatmapweight, heatmapLatitude: heatmapLatitude, heatmapLongtitude: heatmapLongtitude, dataNum: 3))
//        mapView.addOverlay(heatmap)

        mapView.delegate = self
        searchBar.delegate = self
        searchBar.placeholder = "地名 or 住所"

//        callYelpAndUpdateHeatmap("Restaurants", lat: initLatitude, lng: initLongtitude, sort: .BestMatched, categories: ["asianfusion", "burgers"], deals: false)
        //sortに .BestMatched以外を指定すると、Yelpの仕様でtotal=40個しか検索できないので、 .BestMatchedを推奨。

        apiCaller.getHeatmapDataFromHomesApi(heatmapData)
        self.mapView.addOverlay(heatmapData.heatmap)
        
//        apiCallerHotpepper.getShopsFromHotpepper(initLatitude, longtitude: initLongtitude, heatmapData: heatmapData)
        
/*
        //経路の表示
        var fromCoordinate :CLLocationCoordinate2D = CLLocationCoordinate2DMake(35.665213, 139.730011)
        var toCoordinate   :CLLocationCoordinate2D = CLLocationCoordinate2DMake(35.658987, 139.702776)
        var fromPlacemark = MKPlacemark(coordinate:fromCoordinate, addressDictionary:nil)
        var toPlacemark = MKPlacemark(coordinate:toCoordinate, addressDictionary:nil)
        var fromItem = MKMapItem(placemark:fromPlacemark);
        var toItem = MKMapItem(placemark:toPlacemark);
        let request = MKDirectionsRequest();

        request.
    
        request.setSource(fromItem)
        request.setDestination(toItem)
        
        request.requestsAlternateRoutes = true; //複数経路
        request.transportType = MKDirectionsTransportType.Walking //移動手段 Walking:徒歩/Automobile:車

        let directions = MKDirections(request:request)
        directions.calculateDirectionsWithCompletionHandler({
            (response:MKDirectionsResponse!, error:NSError!) -> Void in
            if (error? || response.routes.isEmpty) {
                return
            }
            let route: MKRoute = response.routes[0] as MKRoute
            self.mapView.addOverlay(route.polyline!)
        })

        
        func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
            let route: MKPolyline = overlay as MKPolyline
            let routeRenderer = MKPolylineRenderer(polyline:route)
            routeRenderer.lineWidth = 5.0
            routeRenderer.strokeColor = UIColor.redColor()
            return routeRenderer
        }
*/
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
    //MARK: search bar
    //http://smileapps.sakura.ne.jp/blg/?p=907 , http://swift-salaryman.com/uisearchbar.php
    //検索バーの内容のテキストが変更されると、呼ばれる
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchBar.text) //検索バーの値を取得
    }
    
    // 検索バーにフォーカスが当たると呼ばれる
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        // searchBarからフォーカスを外す（＝キーボードが隠れる）
        searchBar.resignFirstResponder()
        
        // 目的地の文字列から座標検索
        let geocoder = CLGeocoder()
        
//        geocoder.geocodeAddressString(searchBar.text, completionHandler: {(placemarks: [CLPlacemark]?, error: NSError!) -> Void in

    geocoder.geocodeAddressString(searchBar.text!) { (placemarks, error) -> Void in
            if let placemark = placemarks?[0] /*as? CLPlacemark */{
                // 地名を入力して検索リストに有れば緯度経度を取得

                
                
                //Hotpepper API
//                self.apiCallerHotpepper.getShopsFromHotpepper(placemark.location!.coordinate.latitude, longtitude: placemark.location!.coordinate.longitude, heatmapData: self.heatmapData)
                
                //***************** [TODO] 下記処理はコールバックで呼ばないと上記関数でレスポンスが返ってくる前に下記が実行されてしまう問題を抱えています。上記関数のコールバックでaddOverlayを呼ぶようにすること。**********************//
//                self.mapView.addOverlay(self.heatmapData.heatmap)
//                print("heatmap:", self.heatmapData.heatmap)


                //マップを更新
                let updatedLocation:CLLocation? = CLLocation(latitude: placemark.location!.coordinate.latitude, longitude: placemark.location!.coordinate.longitude)
                self.centerMapOnLocation(updatedLocation!)
                
            } else {
                // 検索リストに無ければ
                print("存在しません")
            }
        }
    }

    //_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
    let regionRadius: CLLocationDistance = 1000
    //MARK:centerMapOnLocation
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    //_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
    //MARK: Renderring Overlays
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        //経路
        let route: MKPolyline = overlay as! MKPolyline
        let routeRenderer = MKPolylineRenderer(polyline:route)
        routeRenderer.lineWidth = 5.0
        routeRenderer.strokeColor = UIColor.redColor()
        return routeRenderer
        //経路

        
        let render = DTMHeatmapRenderer(overlay:overlay)
        return render
    }

    func callYelpAndUpdateHeatmap(term: String, lat: Double, lng: Double, sort: YelpSortMode?, categories: [String]?, deals: Bool?){

        let limit = 20
        let radius = 3000
        var responseNum = 0
        var page_index = 0
        var lat_index = 0
        var lng_index = 0
        var totalBusinessNum = 0
        var i = 0
        let areaLengthToGetData = 200
        let latitudePerMeter = 0.000008983148616
        let longitudePerMeter = 0.000010966382364

        page_index = 0
        repeat {
            print("before page: ", page_index)
            Business.searchWithTerm(term, lat: lat, lng: lng, sort: sort, categories: categories, deals: deals, page_index: page_index, limit: limit) {
                (businesses: [Business]!, error: NSError!) -> Void in
                self.yelp_shop = businesses
                
//                print(businesses)

                if(businesses != nil){
                    responseNum = businesses.count
                    for business in businesses {
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

    }
}

