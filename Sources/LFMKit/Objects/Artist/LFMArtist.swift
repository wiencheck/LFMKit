//
//  File.swift
//  
//
//  Created by Adam Wienconek on 01/09/2020.
//

import Foundation

public class LFMArtist: LFMSimplifiedArtist {
    
    public let wiki: Wiki?
        
    public let images: [LFMImage]
    
    public let listeners: UInt
    
    public let playcount: UInt
    
    // MARK: Codable
    private enum CodingKeys: String, CodingKey {
        case wiki = "bio"
        case images = "image"
        case playcount, listeners, stats
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        wiki = try container.decode(Wiki.self, forKey: .wiki)
        images = try container.decode([LFMImage].self, forKey: .images)
        
        if let playcount = try container.decodeIfPresent(UInt.self, forKey: .playcount),
           let listeners = try container.decodeIfPresent(UInt.self, forKey: .listeners) {
            self.playcount = playcount
            self.listeners = listeners
        } else {
            let stats = try container.decode([String: String].self, forKey: .stats)
            guard let playcountString = stats["playcount"],
                  let playcountValue = UInt(playcountString) else {
                throw LFMError.couldNotReadData
            }
            playcount = playcountValue
            
            guard let listenersString = stats["listeners"],
                  let listenersValue = UInt(listenersString) else {
                throw LFMError.couldNotReadData
            }
            listeners = listenersValue
        }
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(wiki, forKey: .wiki)
        try container.encode(images, forKey: .images)
        try container.encode(playcount, forKey: .playcount)
        try container.encode(listeners, forKey: .listeners)
        
        try super.encode(to: encoder)
    }
}

struct ArtistResponse: Decodable {
    let artist: LFMArtist
}
