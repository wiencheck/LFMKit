//
//  File.swift
//  
//
//  Created by Adam Wienconek on 01/09/2020.
//

import Foundation

protocol LFMMethod {
    
    var httpMethod: HTTPMethod { get }
    var name: String { get }
    
}

extension LFMMethod {
    static var apiKey: String { LFM.apiKey }
    
    static var root: String { "ws.audioscrobbler.com" }
    
    static var path: String { "/2.0/" }
}

extension LFMMethod where Self: RawRepresentable, RawValue == String {
    
    var name: String { rawValue }
    
}

extension LFMMethod {
    
    func composed(with params: [String: String]?) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Self.root
        components.path = Self.path
        components.queryItems =
            [URLQueryItem(name: "method", value: name)] +
            (params?.compactMap { key, value in
            return URLQueryItem(name: key, value: value)
        } ?? [])
        return components.url
    }
    
    func request(with params: [String: String]?) -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Self.root
        components.path = Self.path
        components.queryItems =
            [URLQueryItem(name: "method", value: name)] +
            (params?.compactMap { key, value in
            return URLQueryItem(name: key, value: value)
        } ?? [])
        guard let url = components.url else {
            return nil
        }
        return URLRequest(url: url, method: httpMethod)
    }
    
}
