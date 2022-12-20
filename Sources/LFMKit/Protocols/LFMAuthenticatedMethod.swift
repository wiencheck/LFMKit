//
//  File.swift
//  
//
//  Created by Adam Wienconek on 01/09/2020.
//

import Foundation

protocol LFMAuthenticatedMethod: LFMMethod {}

extension LFMAuthenticatedMethod {
    static var apiSecret: String {
        return LFM.apiSecret
    }
}

extension LFMAuthenticatedMethod {
    
    func signed(with params: [String: String]?) -> String {
        var updatedParams = params ?? [:]
        updatedParams["method"] = name
        
        // Parameters have to be sorted alphabetically, according do docs.
        let sortedKeys = updatedParams.keys.sorted(by: <)
        let pairs = sortedKeys.compactMap { key in
            guard let value = updatedParams[key] else { return nil }
            return key + String(describing: value)
        } as [String]
        let str = pairs.joined() + Self.apiSecret
        return str.md5
    }
    
}
