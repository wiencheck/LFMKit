//
//  File.swift
//  
//
//  Created by Adam Wienconek on 01/09/2020.
//

import Foundation

public struct LFMImage: Codable {
    public let url: String
    
    public let size: ImageSize
    
    private enum CodingKeys: String, CodingKey {
        case url = "#text"
        case size
    }
}
