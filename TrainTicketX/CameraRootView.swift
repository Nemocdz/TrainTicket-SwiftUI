//
//  CameraRootView.swift
//  TrainTicketX
//
//  Created by Nemo on 2019/12/27.
//  Copyright © 2019 Nemo. All rights reserved.
//

import SwiftUI

struct CameraRootView: View {
    @State var isShut = false
    
    var didDismiss: () -> ()
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack {
                Button(action: {
                    self.didDismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 25))
                        .frame(width: 25, height: 25)
                        .foregroundColor(.black)
                }
                Spacer()
                Button(action: {
                    /// TODO: open library
                }) {
                    Image(systemName: "photo")
                        .font(.system(size: 25))
                        .frame(width: 25, height: 25)
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            CameraPreviewView(isShut: $isShut, didIdentify: {
                if $0 {
                    self.didDismiss()
                }
                self.isShut = false
            })
            .background(Color.black)
            HStack {
                Spacer()
                Button(action: {
                    self.isShut = true
                }) {
                    Image(systemName: "camera.circle")
                        .font(.system(size: 80))
                        .frame(width: 80, height: 80)
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.vertical, 10)
        }
    }
}

struct CameraRootView_Previews: PreviewProvider {
    static var previews: some View {
        CameraRootView(didDismiss: {})
    }
}
