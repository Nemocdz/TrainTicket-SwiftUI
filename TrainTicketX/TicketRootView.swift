//
//  ContentView.swift
//  TrainTicketX
//
//  Created by Nemo on 2019/10/27.
//  Copyright © 2019 Nemo. All rights reserved.
//

import SwiftUI

struct TicketRootView: View {
    @ObservedObject var dataCenter = DataCenter.shared
    @State var isModalShow = false
    
    var body: some View {
        NavigationView {
            List(dataCenter.tickets) {
                TicketInfoRow(ticket: $0)
            }
            .onAppear {
                //UITableView.appearance().separatorColor = .clear
            }
            .navigationBarTitle("票夹")
            .navigationBarItems(trailing:
                Button(action: {
                    self.isModalShow = true
                }){
                    Image(systemName: "doc.text.viewfinder")
                        .font(.system(size: 25))
                }
                .sheet(isPresented: $isModalShow, content: {
                    CameraRootView(didDismiss: {
                        self.isModalShow = false
                    })
                })
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
                    Text(ticket.startStation)
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                    Spacer()
                    Text(ticket.endStation)
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                }
                Text(ticket.trainNumber)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
            }
            Text(TicketHelper.string(from: ticket.date))
                .font(.system(size: 15))
                .foregroundColor(.black)
            Spacer()
            HStack {
                Text("¥\(String(format: "%.1f", ticket.money))元")
                    .font(.system(size: 15))
                    .foregroundColor(.black)
                Spacer()
                Button(action: {
                    /// TODO: share
                    print("share")
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 25))
                        .frame(width: 25, height: 32)
                        .foregroundColor(.black)
                }
            }
        }
        .frame(height: 200)
        .padding(20)
        .background(Color(ticket.type.color))
        .cornerRadius(10)
    }
}
