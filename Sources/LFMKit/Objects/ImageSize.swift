//
//  File.swift
//  
//
//  Created by Adam Wienconek on 01/09/2020.
//

import Foundation

public enum ImageSize: String, Codable {
    case small, medium, large
    
    // Custom implementation to handle any unknown cases.
    public init(from decoder: Decoder) throws {
        self = try ImageSize(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .small
    }
}
