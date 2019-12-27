//
//  MainTab.swift
//  TrainTicketX
//
//  Created by Nemo on 2019/10/27.
//  Copyright © 2019 Nemo. All rights reserved.
//

import SwiftUI

struct MainTab: View {
    var body: some View {
        TabView {
            TicketRootView().tabItem {
                Image(systemName: "tray.full")
                    .font(.system(size:25))
            }
            PersonRootView().tabItem {
                Image(systemName: "person")
                    .font(.system(size: 25))
            }
        }
    }
}

struct MainTab_Previews: PreviewProvider {
    static var previews: some View {
        MainTab()
    }
}
