//
//  CameraViewController.swift
//  TrainTicketX
//
//  Created by Nemo on 2019/12/27.
//  Copyright © 2019 Nemo. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import SwiftUI
import Toast_Swift
import Combine

struct CameraPreviewView {
    @Binding var isShut:Bool
    var didIdentify:((Bool) -> ())
}

extension CameraPreviewView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func updateUIView(_ uiView: CameraPreviewUIView, context: UIViewRepresentableContext<CameraPreviewView>) {
        if isShut {
            uiView.makeToastActivity(.center)
            uiView.shutPhoto {
                switch $0 {
                    case .success(let data):
                        if let image = UIImage(data: data) {
                            PHPhotoLibrary.shared().performChanges({
                                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                                }) { success, error in
                                    if let error = error {
                                        print(error)
                                    }
                            }
                        }
                        
                        context.coordinator.cancellable = ImageHelper.identify(imageData: data)
                            .receive(on: DispatchQueue.main)
                            .sink(receiveCompletion: { error in
                                uiView.hideToastActivity()
                                print(error)
                                self.didIdentify(false)
                            }) { ticket in
                                uiView.hideToastActivity()
                                DataCenter.shared.tickets.append(ticket)
                                self.didIdentify(true)
                            }
                    case .failure(let error):
                        uiView.hideToastActivity()
                        print(error)
                        self.didIdentify(false)
                }
            }
        }
    }
    
    func makeUIView(context: UIViewRepresentableContext<CameraPreviewView>) -> CameraPreviewUIView {
        CameraPreviewUIView()
    }
    
    class Coordinator {
        var cancellable:AnyCancellable?
    }
}

class CameraPreviewUIView: UIView {
    lazy var cameraLayer:AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    let session:AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = .medium
        return session
    }()
    
    let output = AVCapturePhotoOutput()
    let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if let device = self.device {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                
                layer.insertSublayer(cameraLayer, at: 0)
                session.startRunning()
            } catch {
                print(error)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cameraLayer.frame = bounds
    }
    
    var shutCompletion:((Result<Data, ShutError>) -> ())?
    
    enum ShutError:Error {
        case noDevice
        case noData
        case lockFail(reason:Error)
        case captureError(reason:Error)
    }
    
    func shutPhoto(_ completion:(@escaping (Result<Data, ShutError>) -> ())) {
        guard let device = self.device else {
            completion(.failure(.noDevice))
            return
        }
        
        do {
            try device.lockForConfiguration()
        } catch {
            completion(.failure(.lockFail(reason: error)))
            return
        }
        
        if device.isFocusModeSupported(.autoFocus) {
            device.focusMode = .autoFocus
        }
        
        device.unlockForConfiguration()
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        settings.flashMode = .off
        output.capturePhoto(with:settings, delegate: self)
        shutCompletion = completion
    }
}

extension CameraPreviewUIView: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            shutCompletion?(.failure(.captureError(reason: error)))
        } else {
            if let data = photo.fileDataRepresentation() {
                shutCompletion?(.success(data))
            } else {
                shutCompletion?(.failure(.noData))
            }
        }
    }
}


