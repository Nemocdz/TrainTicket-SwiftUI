//
//  TrainDataCenter.swift
//  TrainTicketX
//
//  Created by Nemo on 2019/10/29.
//  Copyright © 2019 Nemo. All rights reserved.
//

import Foundation
import Combine
import UIKit

enum TrainType:String {
    case K
    case Z
    case C
    case D
    case G
    
    var speed:Float {
        switch self {
            case .K:
                return 80
            case .Z:
                return 100
            case .C:
                return 150
            case .D:
                return 200
            case .G:
                return 300
        }
    }
    
    var color:UIColor {
        switch self {
            case .K, .Z:
                return UIColor(red: 255/255, green: 191/255, blue: 206/255, alpha: 1)
            case .C, .D, .G:
                return UIColor(red: 186/255, green: 232/255, blue: 255/255, alpha: 1)
        }
    }
}

extension TrainType:Codable {
}

struct TrainTicket:Codable {
    // 票号
    let ticketNumber:String
    // 车次
    let trainNumber:String
    // 日期
    let date:Date
    // 起始站
    let startStation:String
    // 终点站
    let endStation:String
    // 金额，单位：元
    let money:Float
    // 运行时长，单位：分钟
    let runTime:Int
    // 距离，单位：公里
    let distance:Float
    // 列车类型
    let type:TrainType
}

final class DataCenter:ObservableObject {
    static let shared = DataCenter()
    private static let fileName = "TicketList.json"
    
    var didChange = PassthroughSubject<DataCenter, Never>()
    
    var tickets:[TrainTicket] = FileHelper.read(from: DataCenter.fileName) {
        didSet {
            didChange.send(self)
            DispatchQueue.global().async {
                FileHelper.write(self.tickets, to: DataCenter.fileName)
            }
        }
    }
    
    private init() {
    }
}



