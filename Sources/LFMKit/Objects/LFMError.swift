//
//  File.swift
//  
//
//  Created by Adam Wienconek on 02/09/2020.
//

import Foundation

struct LFMError: Error, Decodable {
    init(code: Int? = nil, message: String) {
        self.code = code
        self.message = message
    }
    
    let code: Int?
    
    let message: String
    
    private enum CodingKeys: String, CodingKey {
        case code = "error"
        case message
    }
}

extension LFMError: LocalizedError {
    public var localizedDescription: String {
        return message
    }
}
