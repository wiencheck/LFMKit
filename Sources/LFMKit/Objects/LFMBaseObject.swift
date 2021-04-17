//
//  File.swift
//  
//
//  Created by Adam Wienconek on 10/03/2021.
//

import Foundation

public class LFMBaseObject: Codable {
    public let mbid: String
    
    public let name: String
    
    public let url: URL
}

extension LFMBaseObject: CustomStringConvertible {
    public var description: String {
        return "\(name)\nurl: \(url)\n"
    }
}
