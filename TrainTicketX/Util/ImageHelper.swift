//
//  ImageHelper.swift
//  TrainTicketX
//
//  Created by Nemo on 2019/12/27.
//  Copyright © 2019 Nemo. All rights reserved.
//

import Foundation
import Combine

enum ImageHelper {
    enum IdentifyError:Error {
        case noTrainNum
        case noTicketNum
        case OCRError(reason: OCRService.APIError)
    }
    
    static func identify(imageData:Data) -> AnyPublisher<TrainTicket, IdentifyError> {
        OCRService.fetchTicket(imageData: imageData)
        .mapError {
            IdentifyError.OCRError(reason: $0)
        }
        .tryFilter {
            if $0.train_num == nil {
                throw IdentifyError.noTrainNum
            }
            
            if $0.ticket_num == nil {
                throw IdentifyError.noTicketNum
            }
            return true
        }
        .mapError{
            $0 as! IdentifyError
        }
        .flatMap { ticket in
            TrainInfoService.fetchTrain(num: ticket.train_num!)
            .catch{ _ in
                Just(TrainInfoService.TrianInfo())
                    .setFailureType(to: TrainInfoService.APIError.self)
                    .eraseToAnyPublisher()
            }
            .assertNoFailure()
            .setFailureType(to: IdentifyError.self)
            .map{ train in
                createTrainTicket(from: ticket, train)
            }
        }
        .eraseToAnyPublisher()
    }
    
    private static func createTrainTicket(from ticket:OCRService.Ticket, _ train:TrainInfoService.TrianInfo) -> TrainTicket {
        let money:Float = {
            guard let moneyString = ticket.ticket_rates else {
                return 0
            }
            
            return Float(moneyString.filter { $0.isNumber || $0 == "." }) ?? 0
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
