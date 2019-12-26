//
//  TicketHelper.swift
//  TrainTicketX
//
//  Created by Nemo on 2019/12/27.
//  Copyright © 2019 Nemo. All rights reserved.
//

import Foundation

enum TicketHelper {
    static func city(from station:String) -> String {
        var name = station
        if name.last == "站" {
            name.removeLast()
        }
        
        switch name.last {
            case "东","南","西","北":
                name.removeLast()
            default:break
        }
        
        return name
    }
    
    static func string(from date:Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
}
