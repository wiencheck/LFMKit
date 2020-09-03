//
//  File.swift
//  
//
//  Created by Adam Wienconek on 01/09/2020.
//

import Foundation

protocol LFMMethod {
    static var apiKey: String { get }
    static var root: String { get }
}

extension LFMMethod {
    static var apiKey: String {
        return LFM.apiKey
    }
    
    static var root: String {
        return "https://ws.audioscrobbler.com/2.0/"
    }
}

extension LFMMethod where Self: RawRepresentable, RawValue == String {
    func composed(with params: [String: Any]) -> URL? {
        var query = Self.root + "?method=" + rawValue
        let pairs = params.sorted(by: {$0.key < $1.key})
        
        for (key, value) in pairs {
            guard let str = value as? LosslessStringConvertible else {
                continue
            }
            query += "&\(key)=\(str)"
        }
        return URL(string: query)
    }
}
