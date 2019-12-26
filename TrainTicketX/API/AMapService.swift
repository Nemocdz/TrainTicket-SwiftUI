//
//  AMapService.swift
//  TrainTicketX
//
//  Created by Nemo on 2019/12/27.
//  Copyright © 2019 Nemo. All rights reserved.
//

import Foundation

enum AMapService {
    static let appKey = "5a31783a46b8bb4a70f70dcef8023d0e"
    
    static func start() {
        AMapServices.shared().enableHTTPS = true
        AMapServices.shared().apiKey = AMapService.appKey
    }
}
