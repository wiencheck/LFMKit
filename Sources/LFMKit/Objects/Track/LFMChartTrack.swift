//
//  File.swift
//  
//
//  Created by Adam Wienconek on 11/03/2021.
//

import Foundation

// znajduje się na weekly track chart
public class LFMChartTrack: ChartItem {
    override class var key: String {
        return "track"
    }
    
    public let artist: LFMSimplifiedChartArtist
    
    // MARK: Codable
    private enum CodingKeys: String, CodingKey {
        case artist
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        artist = try container.decode(LFMSimplifiedChartArtist.self, forKey: .artist)
        
        try super.init(from: decoder)
    }
}
