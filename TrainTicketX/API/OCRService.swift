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
        .mapError {
            $0 as! APIError
        }
        .map { value -> URLRequest in
            var request = URLRequest(url: URL(string: "https://aip.baidubce.com/rest/2.0/ocr/v1/train_ticket?access_token=\(accessToken)")!)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = "image=\(escape(value))".data(using: .utf8)
            return request
        }
        .flatMap {
            URLSession.shared.dataTaskPublisher(for: $0)
                .mapError {
                    APIError.networkError($0)
            }
        }
        .map { $0.data }
        .decode(type: OCRResult.self, decoder: JSONDecoder())
        .mapError { _ in
            APIError.decodeError
        }
        .tryMap {
            guard let result = $0.words_result else {
                throw APIError.resultError(code: $0.error_code ?? -1, message: $0.error_msg ?? "unknown")
            }
            return result
        }
        .mapError {
            $0 as! APIError
        }
        .eraseToAnyPublisher()
    }
    
    static func escape(_ string: String) -> String {
        string.replacingOccurrences(of: "\n", with: "\r\n")
            .addingPercentEncoding(withAllowedCharacters: URLQueryAllowed) ?? string
            .replacingOccurrences(of: " ", with: "+")
    }
    
    static let URLQueryAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        let encodableDelimiters = CharacterSet(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return CharacterSet.urlQueryAllowed.subtracting(encodableDelimiters)
    }()
}

