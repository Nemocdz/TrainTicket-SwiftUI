//
//  ShareView.swift
//  TrainTicketX
//
//  Created by Nemo on 2019/12/27.
//  Copyright © 2019 Nemo. All rights reserved.
//

import SwiftUI
import UIKit

struct ShareView {
}


extension ShareView: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareView>) -> UIActivityViewController {
        UIActivityViewController(activityItems: [], applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareView>) {
        
    }
}

