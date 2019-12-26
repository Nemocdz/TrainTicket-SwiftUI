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
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            fatalError()
        }
        
        do {
            let data = try JSONEncoder().encode(object)
            try data.write(to: fileURL)
        } catch {
            fatalError()
        }
    }
    
    static func read<T: Decodable>(from fileName: String) -> T {
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            fatalError()
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            fatalError()
        }
    }
}
