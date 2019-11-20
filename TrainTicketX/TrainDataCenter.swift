//
//  TrainDataCenter.swift
//  TrainTicketX
//
//  Created by Nemo on 2019/10/29.
//  Copyright © 2019 Nemo. All rights reserved.
//

import Foundation
import Combine

fileprivate let trainListFileName = "TicketList.json"

struct TrainTicket:Decodable {
    // 车次
    let trainNumber:String
    // 日期
    let date:Date
    // 起始站
    let startStation:String
    // 终点站
    let endStation:String
    // 金额，单位：元
    let money:Float
    // 运行时长，单位：分钟
    let runTime:Int
    // 距离，单位：公里
    let distance:Float
}

enum OCRService {
    static let accessToken = "24.cfe2fef6fa76cb34d5785af2a81a9fa2.2592000.1574060179.282335-17566606"
    
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
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
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

enum TrainInfoService {
    static let appKey = "9e82d97bdceb4fadbe43e00a7618c1fd"
    
    struct TrianInfo:Codable {
        var start_station:String?
        var end_station:String?
        var start_time:String?
        var end_time:String?
        var run_time:String?
        var run_distance:String?
    }
    
    struct TrainResult:Codable {
        var result:TrianInfo?
    }
    
    enum APIError:Error {
        case unknown
        case networkError(Error)
        case resultError
        case decodeError
    }
    
    static func fetchTrain(num:String) -> AnyPublisher<TrianInfo, APIError> {
        Just(num)
        .setFailureType(to: Error.self)
        .map { value -> URLRequest in
            var request = URLRequest(url: URL(string: "http://api.avatardata.cn/Train/QueryByTrain?key=\(appKey)&train=\(value)")!)
            request.httpMethod = "GET"
            return request
        }
        .flatMap {
            URLSession.shared.dataTaskPublisher(for: $0).mapError { error -> Error in
                APIError.networkError(error)
            }
        }
        .map { $0.data }
        .decode(type: TrainResult.self, decoder: JSONDecoder())
        .tryMap {
            guard let result = $0.result else {
                throw APIError.resultError
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



final class TrainDataCenter {
    static let shared = TrainDataCenter()
    
    @Published var tickets:[TrainTicket]
    private init() {
        tickets = load(trainListFileName)
    }

    
}


fileprivate func load<T: Decodable>(_ filename: String, as type: T.Type = T.self) -> T {
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        let data = try Data(contentsOf: file)
        return try JSONDecoder().decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

