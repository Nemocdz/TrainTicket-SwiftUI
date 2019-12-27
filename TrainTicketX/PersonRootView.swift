//
//  PersonRootView.swift
//  TrainTicketX
//
//  Created by Nemo on 2019/10/27.
//  Copyright © 2019 Nemo. All rights reserved.
//

import SwiftUI

struct PersonRootView: View {
    @ObservedObject var dataCenter = DataCenter.shared
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("行程图")) {
                    TrainMapView(trainLines: dataCenter.tickets.map{ TrainLine(startStationName: $0.startStation, endStationName: $0.endStation, trainType: $0.type) })
                        .frame(height: 400)
                }
                Section(header: Text("数据")) {
                    DataInfoRow(title: "总金额", detail: "\(String(format: "%.1f", dataCenter.tickets.reduce(0, { $0 + $1.money }))) 元")
                    DataInfoRow(title: "最常用路线", detail: "\(rareLine())")
                    DataInfoRow(title: "总公里数", detail: "\(Int(dataCenter.tickets.reduce(0, { $0 + $1.distance }))) 公里")
                    DataInfoRow(title: "总时长", detail: "\(totalMinute() / (60 * 60)) 天 \(totalMinute() % (60 * 60) / 60) 小时")
                    DataInfoRow(title: "总行程数", detail: "\(dataCenter.tickets.count) 趟")
                    DataInfoRow(title: "去过的城市数", detail: "\(cityCount()) 个")
                }
            }
            .navigationBarTitle("汇总")
        }
    }
    
    func cityCount() -> Int {
        var citys = Set<String>()
        dataCenter.tickets.forEach {
            citys.insert(TicketHelper.city(from: $0.startStation))
            citys.insert(TicketHelper.city(from: $0.endStation))
        }
        return citys.count
    }
    
    func rareLine() -> String {
        var map = [String: Int]()
        dataCenter.tickets.forEach {
            let line = "\(TicketHelper.city(from: $0.startStation))-\(TicketHelper.city(from: $0.endStation))"
            if let value = map[line] {
                map[line] = value + 1
            } else {
                map[line] = 1
            }
        }
        
        return map.max(by: { $0.value > $1.value })?.key ?? ""
    }
    
    func totalMinute() -> Int {
        dataCenter.tickets.reduce(0) { $0 + $1.runTime }
    }
}

struct DataInfoRowModel:Hashable {
    let titleText:String
    let detailText:String
}

struct DataInfoRow: View {
    let title:String
    @State var detail:String
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(detail)
        }
    }
}

struct PersonRootView_Previews: PreviewProvider {
    static var previews: some View {
        PersonRootView()
    }
}
