//
//  TrainAPI.swift
//  TrainTicketX
//
//  Created by Nemo on 2019/10/27.
//  Copyright © 2019 Nemo. All rights reserved.
//

import Foundation
import Combine

enum TrainAPI {
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
        var run_time:String?
    }
    
    struct OCRResult:Codable {
        //var words_result_num:String?
        var words_result:Ticket?
        var log_id:Int?
        var error_code: Int?
        var error_msg: String?
    }
    
    struct TrainInfoResult:Codable {
        var result:TrainInfo?
    }
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
    struct TrainInfo:Codable {
        var run_time: String?
        var run_distance: String?
    }
    // Nemo
    //static let accessToken = "24.cfe2fef6fa76cb34d5785af2a81a9fa2.2592000.1574060179.282335-17566606"
    
    // LLL
    static let accessToken = "24.fecd9e75b03e854a5c75e09a24ec46f5.2592000.1574146370.282335-17573343"
    static let appkey = "9e82d97bdceb4fadbe43e00a7618c1fd"
    static var isLoading = false
    static func ticket(for imageData:Data, completion:(@escaping (Result<Ticket,Error>) -> ())) {
        guard !isLoading else {
            completion(.failure(NSError()))
            return
        }
        let imageValue = imageData.base64EncodedString()
        guard imageValue.count < 4000000 else {
            completion(.failure(NSError()))
            return
        }
        isLoading = true
        defer {
            isLoading = false
        }
        
//        var request = URLRequest(url: URL(string: "https://aip.baidubce.com/rest/2.0/ocr/v1/train_ticket?access_token=\(accessToken)")!)
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.httpMethod = "POST"
//        request.httpBody = "image=\(imageValue)".data(using: .utf8)
//        URLSession.shared.dataTask(with: request) { data, _, error in
//            if let error = error {
//                completion(.failure(error))
//            } else if let data = data {
//                do {
//                    let result = try JSONDecoder().decode(OCRResult.self, from: data)
//                    if let ticket = result.words_result {
//                        completion(.success(ticket))
//                    } else {
//                        let error = NSError()
//                        completion(.failure(error))
//                    }
//                } catch {
//                    completion(.failure(error))
//                }
//            }
//        }.resume()
        
        
//        AF.request("https://aip.baidubce.com/rest/2.0/ocr/v1/train_ticket?access_token=\(accessToken)",
//            method: .post,
//            parameters: ["image":imageValue],
//            headers: ["Content-Type":"application/x-www-form-urlencoded"]).responseJSON { response in
//                switch response.result {
//                case .success(let JSONDic):
//                    do {
//                        let JSONData = try JSONSerialization.data(withJSONObject: JSONDic, options: .prettyPrinted)
//                        let result = try JSONDecoder().decode(OCRResult.self, from: JSONData)
//                        if let ticket = result.words_result {
//                            completion(.success(ticket))
//                        } else {
//                            let error = NSError()
//                            completion(.failure(error))
//                        }
//                    } catch {
//                        completion(.failure(error))
//                    }
//                case .failure(let error):
//                    completion(.failure(error))
//                }
//        }
        
    }
    
    static func trainInfo(for trainNum:String, completion:(@escaping (Result<TrainInfo, Error>) -> ())) {
        
        URLSession.shared
            .dataTaskPublisher(for: URL(string: "http://api.avatardata.cn/Train/QueryByTrain?key=\(appkey)&train=\(trainNum)")!)
            .map { data, _ in data }
            .decode(type: TrainInfoResult.self, decoder: JSONDecoder())
        
//        AF.request("http://api.avatardata.cn/Train/QueryByTrain?key=\(appkey)&train=\(trainNum)").responseJSON { response in
//            switch response.result {
//            case .success(let JSONDic):
//                do {
//                    let JSONData = try JSONSerialization.data(withJSONObject: JSONDic, options: .prettyPrinted)
//                    let result = try JSONDecoder().decode(TrainInfoResult.self, from: JSONData)
//                    if let info = result.result {
//                        completion(.success(info))
//                    } else {
//                        let error = NSError()
//                        completion(.failure(error))
//                    }
//                } catch {
//                    completion(.failure(error))
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
    }
}

