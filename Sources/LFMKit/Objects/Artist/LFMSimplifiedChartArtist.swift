//
//  File.swift
//  
//
//  Created by Adam Wienconek on 11/03/2021.
//

import Foundation

// pojawia się w album chart
public class LFMSimplifiedChartArtist: Codable {
    public let mbid: String
    
    public let name: String
    
    private enum CodingKeys: String, CodingKey {
        case mbid
        case name = "#text"
    }
}
