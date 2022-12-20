//
//  File.swift
//  
//
//  Created by Adam Wienconek on 11/03/2021.
//

import Foundation

public class LFMChartAlbum: ChartItem {
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
