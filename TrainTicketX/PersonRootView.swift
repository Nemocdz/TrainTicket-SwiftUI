//
//  PersonRootView.swift
//  TrainTicketX
//
//  Created by Nemo on 2019/10/27.
//  Copyright © 2019 Nemo. All rights reserved.
//

import SwiftUI

let dataInfos = [DataInfoRowModel(titleText:"总金额", detailText:"0 元"),
                 DataInfoRowModel(titleText:"最常用路线", detailText:"北京-上海"),
                 DataInfoRowModel(titleText:"总公里数", detailText:"0 公里"),
                 DataInfoRowModel(titleText:"总时长", detailText:"0 天 0 小时")]


struct PersonRootView: View {
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("行程图")) {
                    Text("aa")
                }
                Section(header: Text("数据")) {
                    ForEach(dataInfos, id: \.self) {
                        DataInfoRow(model: $0)
                    }
                }
            }.navigationBarTitle("汇总")
        }
    }
}

struct DataInfoRowModel:Hashable {
    let titleText:String
    let detailText:String
}

struct DataInfoRow: View {
    let model:DataInfoRowModel
    var body: some View {
        HStack {
            Text(model.titleText)
            Spacer()
            Text(model.detailText)
        }
    }
}

struct PersonRootView_Previews: PreviewProvider {
    static var previews: some View {
        PersonRootView()
    }
}
