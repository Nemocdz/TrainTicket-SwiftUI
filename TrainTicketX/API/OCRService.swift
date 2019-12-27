//
//  OCRService.swift
//  TrainTicketX
//
//  Created by Nemo on 2019/12/27.
//  Copyright © 2019 Nemo. All rights reserved.
//

import Foundation
import Combine

enum OCRService {
    static let accessToken = "24.610182d20abf58ba04b0391a967f7721.2592000.1579965849.282335-18117539"
    
    /*
     "name": "随乘车证有效",
     "destination_station": "襄阳站",
     "seat_category": "新空调硬卧",
     "ticket_rates": "￥2.0元",
     "ticket_num": "215A096005",
     "date": "2016年11月04日",
     "train_num": "T284",
     "starting_station": "哈密站"
     */
    struct Ticket:Codable {
        var name:String?
        var date:String?
        var ticket_num:String?
        var train_num:String?
        var seat_category:String?
        var ticket_rates:String?
        var starting_station:String?
        var destination_station:String?
    }
    
    struct OCRResult:Codable {
        var words_result:Ticket?
        var log_id:Int?
        var error_code: Int?
        var error_msg: String?
    }
    
    enum APIError:Error {
        case unknown
        case imageDataSizeLimit(base64Size:Int)
        case networkError(Error)
        case decodeError
        case resultError(code:Int, message:String)
    }
    
    static func fetchTicket(imageData:Data) -> AnyPublisher<Ticket, APIError> {
        Just(imageData)
        .map{ $0.base64EncodedString() }
        .tryMap { value -> String in
            guard value.count < 4 * 1000 * 1000 else {
                throw APIError.imageDataSizeLimit(base64Size: value.count)
            }
            return value
        }
        .map { value -> URLRequest in
            var request = URLRequest(url: URL(string: "https://aip.baidubce.com/rest/2.0/ocr/v1/train_ticket?access_token=\(accessToken)")!)
            request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = "image=\(value)".data(using: .utf8)
            return request
        }
        .flatMap {
            URLSession.shared.dataTaskPublisher(for: $0).mapError { error -> Error in
                APIError.networkError(error)
            }
        }
        .map { $0.data }
        .decode(type: OCRResult.self, decoder: JSONDecoder())
        .tryMap {
            guard let result = $0.words_result else {
                throw APIError.resultError(code: $0.error_code ?? -1, message: $0.error_msg ?? "unknown")
            }
            return result
        }
        .mapError {
            switch $0 {
            case let error as APIError: return error
            case is DecodingError: return APIError.decodeError
            default: return APIError.unknown
            }
        }
        .eraseToAnyPublisher()
    }
}
