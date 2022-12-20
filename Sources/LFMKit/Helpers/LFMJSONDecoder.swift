//
//  File.swift
//  
//
//  Created by Adam Wienconek on 03/12/2020.
//

import Foundation

final class LFMJSONDecoder: JSONDecoder {
    override init() {
        super.init()
        dateDecodingStrategy = .iso8601
    }
}
