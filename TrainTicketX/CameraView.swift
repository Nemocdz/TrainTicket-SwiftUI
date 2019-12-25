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
import Combine

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
    enum IdentifyError:Error {
        case unknown
        case OCRError
        case trainInfoError
    }
    
    static func identify(imageData:Data) -> AnyPublisher<TrainTicket, IdentifyError> {
        OCRService.fetchTicket(imageData: imageData)
        .mapError { error -> IdentifyError in
            switch error {
            case .unknown: return IdentifyError.unknown
            default:
                print(error)
                return IdentifyError.OCRError
            }
        }
        .tryFilter {
            let isValid = $0.train_num != nil && $0.ticket_num != nil
            guard isValid else {
                throw IdentifyError.OCRError
            }
            return isValid
        }
        .flatMap { ticket in
            TrainInfoService.fetchTrain(num: ticket.train_num!)
            .map{ train in
                createTrainTicket(from: ticket, train)
            }
            .mapError { error -> IdentifyError in
                switch error {
                case .unknown: return IdentifyError.unknown
                default:
                    print(error)
                    return IdentifyError.trainInfoError
                }
            }
        }
        .mapError {
            switch $0 {
            case let error as IdentifyError: return error
            default: return IdentifyError.unknown
            }
        }
        .eraseToAnyPublisher()
    }
    
    static func createTrainTicket(from ticket:OCRService.Ticket, _ train:TrainInfoService.TrianInfo) -> TrainTicket {
        let money:Float = {
            guard let moneyString = ticket.ticket_rates else {
                return 0
            }
            
            return Float(moneyString.filter { $0.isNumber }) ?? 0
        }()
        
        let date:Date = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "zh_CN")
            formatter.dateFormat = "yyyy年MM月dd日"
            return formatter.date(from: ticket.date ?? "") ?? Date()
        }()
        
        let runTime:Int = {
            guard var string = train.run_time else {
                return 0
            }
            
            let day:Int = {
                let array = string.components(separatedBy: "天")
                guard array.count >= 2 else {
                    return 0
                }
                string = array[1]
                return Int(array.first!) ?? 0
            }()
            
            let hour:Int = {
                let array = string.components(separatedBy: "小时")
                guard array.count >= 2 else {
                    return 0
                }
                string = array[1]
                return Int(array.first!) ?? 0
            }()
            
            let minute:Int = {
                let array = string.components(separatedBy: "小时")
                guard array.count >= 1 else {
                    return 0
                }
                return Int(array.first!) ?? 0
            }()
            
            return day * 24 * 60 + hour * 60 + minute
        }()
        
        let type:TrainType = {
            guard let first = ticket.train_num?.first?.uppercased() else {
                return .K
            }
            
            return TrainType(rawValue: first) ?? .K
        }()
        
        let distance:Float = {
            return type.speed * Float(runTime) / 60
        }()
    
        return TrainTicket(ticketNumber: ticket.ticket_num ?? "", trainNumber: ticket.train_num ?? "", date: date, startStation: ticket.starting_station ?? "", endStation: ticket.destination_station ?? "" , money: money, runTime: runTime, distance: distance, type: type)
    }
}

extension ImagePickerCoordinator:UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let data = image.pngData() else { return }
        ImagePickerCoordinator.identify(imageData: data).sink(receiveCompletion: { error in
            /// TODO: show toast
        }) { value in
            /// TODO: add ticket
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
}

extension ImagePickerCoordinator:UINavigationControllerDelegate {
}


