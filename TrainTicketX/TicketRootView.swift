//
//  ContentView.swift
//  TrainTicketX
//
//  Created by Nemo on 2019/10/27.
//  Copyright © 2019 Nemo. All rights reserved.
//

import SwiftUI

struct TicketRootView: View {
    @ObservedObject var dataCenter = TrainDataCenter.shared
    
    var body: some View {
        NavigationView {
            List(dataCenter.tickets) {
                TicketInfoRow(ticket: $0)
            }.onAppear {
                //UITableView.appearance().separatorColor = .clear
            }.navigationBarTitle("票夹").navigationBarItems(trailing:
                NavigationLink (destination: CameraView()) {
                    Image(systemName: "doc.text.viewfinder").font(.system(size: 25))
                }
            )}
    }
}

extension TrainTicket:Identifiable {
    var id:String {
        ticketNumber
    }
}

struct TicketRootView_Previews: PreviewProvider {
    static var previews: some View {
        TicketRootView()
    }
}

struct TicketInfoRow: View {
    @State var ticket:TrainTicket
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                HStack {
                    Text(ticket.startStation).font(.system(size: 18))
                    Spacer()
                    Text(ticket.endStation).font(.system(size: 18))
                }
                Text(ticket.trainNumber).font(.system(size: 16))
            }
            Text(TicketUtil.string(from: ticket.date)).font(.system(size: 15))
            Spacer()
            HStack {
                Text("¥\(String(format: "%.1f", ticket.money))元").font(.system(size: 15))
                Spacer()
                Button(action: {
                    /// TODO: share
                    print("share")
                }) {
                    Image(systemName: "square.and.arrow.up").font(.system(size: 25)).frame(width: 25, height: 32).foregroundColor(.white)
                }
            }
        }.frame(height: 200).padding(20).background(Color(ticket.type.color)).cornerRadius(10)
    }
}
