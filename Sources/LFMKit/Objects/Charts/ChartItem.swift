//
//  File.swift
//  
//
//  Created by Adam Wienconek on 11/03/2021.
//

import Foundation

public class ChartItem: LFMBaseObject {
    class var key: String {
        fatalError("*** Must override")
    }
    
    public let rank: UInt
    
    public let playcount: UInt
    
    // MARK: Codable
    private enum CodingKeys: String, CodingKey {
        case playcount, rank
        case attributes = "@attr"
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let playcountString = try container.decode(String.self, forKey: .playcount)
        guard let playcountValue = UInt(playcountString) else {
            throw LFMError.couldNotReadData
        }
        playcount = playcountValue
        
        let attributes = try container.decode([String: String].self, forKey: .attributes)
        guard let rankString = attributes["rank"],
              let rankValue = UInt(rankString) else {
            throw LFMError.couldNotReadData
        }
        rank = rankValue
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(playcount, forKey: .playcount)
        try container.encode(rank, forKey: .rank)
        
        try super.encode(to: encoder)
    }
}
