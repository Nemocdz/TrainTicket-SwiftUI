//
//  FileHelper.swift
//  TrainTicketX
//
//  Created by Nemo on 2019/12/27.
//  Copyright © 2019 Nemo. All rights reserved.
//

import Foundation

enum FileHelper {
    static func write<T: Encodable>(_ object:T, to fileName: String) {
        guard let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName) else {
            return
        }
        
        do {
            
            let data = try JSONEncoder().encode(object)
            try data.write(to: fileURL)
        } catch {
            print(error)
        }
    }
    
    static func read<T: Decodable>(from fileName: String) -> T? {
        guard let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print(error)
        }
        
        return nil
    }
}
