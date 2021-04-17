//
//  File.swift
//  
//
//  Created by Adam Wienconek on 01/09/2020.
//

import Foundation

public class LFMAlbum: LFMBaseObject {
    public let artist: String
        
    public let playcount: UInt
    
    public let listeners: UInt
    
    public let releaseDate: Date?

    public let wiki: Wiki?
    
    public let images: [LFMImage]
    
    // - MARK: Codable
    private enum CodingKeys: String, CodingKey {
        case artist, playcount, wiki, listeners
        case releaseDate = "releasedate"
        case images = "image"
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        artist = try container.decode(String.self, forKey: .artist)
        images = try container.decode([LFMImage].self, forKey: .images)
        releaseDate = try container.decodeIfPresent(Date.self, forKey: .releaseDate)
        wiki = try container.decodeIfPresent(Wiki.self, forKey: .wiki)
        
        if let playcount = try? container.decode(UInt.self, forKey: .playcount) {
            self.playcount = playcount
        } else {
            let playcountString = try container.decode(String.self, forKey: .playcount)
            guard let playcountValue = UInt(playcountString) else {
                throw LFMError.couldNotReadData
            }
            playcount = playcountValue
        }
        
        if let listeners = try? container.decode(UInt.self, forKey: .listeners) {
            self.listeners = listeners
        } else {
            let listenersString = try container.decode(String.self, forKey: .listeners)
            guard let listenersValue = UInt(listenersString) else {
                throw LFMError.couldNotReadData
            }
            listeners = listenersValue
        }
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(artist, forKey: .artist)
        try container.encode(images, forKey: .images)
        try container.encode(releaseDate, forKey: .releaseDate)
        try container.encode(wiki, forKey: .wiki)
        try container.encode(playcount, forKey: .playcount)
        try container.encode(listeners, forKey: .listeners)
        
        try super.encode(to: encoder)
    }
}

struct AlbumResponse: Decodable {
    let album: LFMAlbum
}
