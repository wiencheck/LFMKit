//
//  File.swift
//  
//
//  Created by Adam Wienconek on 03/12/2020.
//

import Foundation

extension URLRequest {
    init(url: URL, method: HTTPMethod) {
        self.init(url: url)
        httpMethod = method.rawValue
    }
}
