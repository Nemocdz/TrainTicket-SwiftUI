//
//  TrainInfoService.swift
//  TrainTicketX
//
//  Created by Nemo on 2019/12/27.
//  Copyright © 2019 Nemo. All rights reserved.
//

import Foundation
import Combine

enum TrainInfoService {
    static let appKey = "9e82d97bdceb4fadbe43e00a7618c1fd"
    
    /*
     "train_no": "Z27",
     "train_type": "直达",
     "start_station": "上海南",
     "start_station_type": "始",
     "end_station": "武昌",
     "end_station_type": "终",
     "start_time": "21:02",
     "end_time": "次日06:35",
     "run_time": "9小时33分钟",
     "run_distance": "",
     "price_list": null
    */
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
