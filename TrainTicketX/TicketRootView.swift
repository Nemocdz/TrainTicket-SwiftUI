//
//  ContentView.swift
//  TrainTicketX
//
//  Created by Nemo on 2019/10/27.
//  Copyright © 2019 Nemo. All rights reserved.
//

import SwiftUI

struct Model:Identifiable {
    let num:Int
    var id:Int { num }
}

let models = [Model(num: 1), Model(num: 2), Model(num: 3)]

struct TicketRootView: View {
    var body: some View {
        NavigationView {
            List(models) { _ in
                TicketInfoRow()
            }.onAppear {
                //UITableView.appearance().separatorColor = .clear
            }.navigationBarTitle("票夹").navigationBarItems(trailing:
                NavigationLink (destination: Text("AAAA")) {
                    Image(systemName: "doc.text.viewfinder").font(.system(size: 25))
                }
            )}
    }
}

struct TicketRootView_Previews: PreviewProvider {
    static var previews: some View {
        TicketRootView()
    }
}

struct TicketInfoRow: View {
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                HStack {
                      Text("广州东").font(.system(size: 18))
                      Spacer()
                      Text("深圳北").font(.system(size: 18))
                  }
                  Text("C7071").font(.system(size: 16))
            }
            Text("2019年7月18日").font(.system(size: 15))
            Spacer()
            HStack {
                Text("¥79.5元").font(.system(size: 15))
                Spacer()
                Button(action: {
                    
                }) {
                    Image(systemName: "square.and.arrow.up").font(.system(size: 25)).frame(width: 25, height: 32).foregroundColor(.white)
                }
            }
        }.frame(height: 200).padding(20).background(Color.blue).cornerRadius(10)
    }
}
