//
//  PhotoLibraryView.swift
//  TrainTicketX
//
//  Created by Nemo on 2019/12/27.
//  Copyright © 2019 Nemo. All rights reserved.
//

import SwiftUI
import Combine
import Toast_Swift

struct PhotoLibraryView: View {
    var didIdentify:((Bool) -> ())
}

extension PhotoLibraryView: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(didIdentify: didIdentify)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<PhotoLibraryView>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<PhotoLibraryView>) {
        
    }
    
    class Coordinator: NSObject {
        var didIdentify:((Bool) -> ())
        var cancellable:AnyCancellable?
        
        init(didIdentify:@escaping((Bool) -> ())) {
            self.didIdentify = didIdentify
        }
    }
}

extension PhotoLibraryView.Coordinator: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        didIdentify(false)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.view.makeToastActivity(.center)
        if let image = info[.originalImage] as? UIImage, let data = image.jpegData(compressionQuality: 90) {
            cancellable = ImageHelper.identify(imageData: data)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { error in
                    picker.view.hideToastActivity()
                    print(error)
                    //self.didIdentify(false)
            }) { ticket in
                picker.view.hideToastActivity()
                DataCenter.shared.tickets.append(ticket)
                self.didIdentify(true)
            }
        } else {
            /// TODO: showToast
            picker.view.hideToastActivity()
        }
    }
}

extension PhotoLibraryView.Coordinator: UINavigationControllerDelegate {
    
}


