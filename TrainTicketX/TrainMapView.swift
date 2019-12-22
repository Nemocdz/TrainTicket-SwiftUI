//
//  TrainMapView.swift
//  TrainTicket
//
//  Created by Nemo on 2019/10/19.
//  Copyright © 2019 cn.com.yousanflics.hackathon. All rights reserved.
//

import UIKit
import AMapSearchKit
import AMapFoundationKit
import SwiftUI

struct TrainLine {
    let startStationName:String
    let endStationName:String
    let trainType:TrainType
}

struct ATrainMapView {
    @Binding var trainLines:[TrainLine]
}

extension ATrainMapView: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<ATrainMapView>) -> TrainMapView {
        TrainMapView()
    }
    
    func updateUIView(_ uiView: TrainMapView, context: UIViewRepresentableContext<ATrainMapView>) {
        uiView.lines = trainLines
    }
}

class TrainMapView: UIView {
    lazy var mapView: MAMapView = {
        let mapView = MAMapView(frame: bounds)
        mapView.zoomLevel = 4
        mapView.delegate = self
        return mapView
    }()
    
    let searchAPI = AMapSearchAPI()!
    
    var locationPoints = [CLLocationCoordinate2D]()
    var pendingLines = [TrainLine]()
    var isLoading = false
    var trainType = TrainType.K
    
    var lines:[TrainLine] = [] {
        didSet {
            lines.forEach {
                addLine($0)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mapView)
        searchAPI.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func addLine(_ line:TrainLine) {
        func makeRequest(for stationName:String) -> AMapPOIKeywordsSearchRequest {
            let cityName:String? = {
                var name = stationName
                if name.last == "站" {
                    name.removeLast()
                }
                
                switch name.last {
                    case "东","南","西","北":
                        name.removeLast()
                    default:break
                }
                
                return name == stationName ? nil : name
            }()
            
            let request = AMapPOIKeywordsSearchRequest()
            
            if cityName != nil {
                request.city = cityName!
            }
            
            request.keywords = stationName
            return request
        }
        
        if isLoading {
            pendingLines.append(line)
        } else {
            isLoading = true
            locationPoints.removeAll()
            searchAPI.aMapPOIKeywordsSearch(makeRequest(for: line.startStationName))
            searchAPI.aMapPOIKeywordsSearch(makeRequest(for: line.endStationName))
            trainType = line.trainType
        }
    }
}

extension TrainMapView:AMapSearchDelegate {
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if let poi = response.pois.first {
            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(poi.location.latitude), longitude: CLLocationDegrees(poi.location.longitude))
            locationPoints.append(coordinate)
            let anno = MAPointAnnotation()
            anno.coordinate = coordinate
            mapView.addAnnotation(anno)
        }
        
        if locationPoints.count == 2 {
            let polyline = MAPolyline(coordinates: &locationPoints, count: UInt(locationPoints.count))
            mapView.add(polyline)
            isLoading = false
            if !pendingLines.isEmpty {
                addLine(pendingLines.removeFirst())
            }
        }
    }
}

extension TrainMapView:MAMapViewDelegate {
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if let renderer = MAPolylineRenderer(overlay: overlay) {
            renderer.lineWidth = 3.0
            renderer.strokeColor = trainType.color
            return renderer
        }
        return nil
    }
}
