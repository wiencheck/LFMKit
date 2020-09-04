//
//  File.swift
//  
//
//  Created by Adam Wienconek on 01/09/2020.
//

import Foundation

protocol LFMAuthenticatedMethod: LFMMethod {
    static var apiSecret: String { get }
}

extension LFMAuthenticatedMethod {
    static var apiSecret: String {
        return LFM.apiSecret
    }
}

extension LFMAuthenticatedMethod where Self: RawRepresentable, RawValue == String {
    func signed(with params: [String: Any]) -> String {
        var updatedParams = params
        updatedParams["method"] = rawValue
        
        // Parameters have to be sorted alphabetically, according do docs.
        let sortedKeys = updatedParams.keys.sorted(by: <)
        let pairs = sortedKeys.compactMap { key in
            guard let value = updatedParams[key] as? LosslessStringConvertible else { return nil }
            return key + String(describing: value)
        } as [String]
        let str = pairs.joined() + Self.apiSecret
        return str.md5
    }
}
