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
        return "ws.audioscrobbler.com"
    }
    
    static var path: String {
        return "/2.0/"
    }
}

extension LFMMethod where Self: RawRepresentable, RawValue == String {
    func composed(with params: [String: String]) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Self.root
        components.path = Self.path
        components.queryItems =
            [URLQueryItem(name: "method", value: rawValue)] +
            params.compactMap { key, value in
            return URLQueryItem(name: key, value: value)
        }
        return components.url
    }
}
