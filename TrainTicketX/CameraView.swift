//
//  CameraView.swift
//  TrainTicketX
//
//  Created by Nemo on 2019/12/16.
//  Copyright © 2019 Nemo. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

struct CameraView {
    
}

extension CameraView:UIViewControllerRepresentable {
    func makeCoordinator() -> ImagePickerCoordinator {
        ImagePickerCoordinator()
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CameraView>) -> UIImagePickerController {
        let viewController = UIImagePickerController()
        viewController.delegate = context.coordinator
        viewController.sourceType = .camera
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<CameraView>) {
        
    }
}

class ImagePickerCoordinator:NSObject {
    
}

extension ImagePickerCoordinator:UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let data = image.pngData() else { return }
        OCRService.fetchTicket(imageData: data)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
}

extension ImagePickerCoordinator:UINavigationControllerDelegate {
}


