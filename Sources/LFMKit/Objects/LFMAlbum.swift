//
//  File.swift
//  
//
//  Created by Adam Wienconek on 01/09/2020.
//

import Foundation

public struct LFMAlbum: Codable {
    public let name: String
    
    public let artist: String
    
    public let url: String
    
    public let releaseDate: Date?
    
    public let images: [LFMImage]

    public let wiki: Wiki?
    
    private enum CodingKeys: String, CodingKey {
        case name, artist, url, wiki
        case releaseDate = "releasedate"
        case images = "image"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        artist = try container.decode(String.self, forKey: .artist)
        url = try container.decode(String.self, forKey: .url)
        images = try container.decode([LFMImage].self, forKey: .images)
        wiki = try? container.decode(Wiki.self, forKey: .wiki)
        
        if let date = try container.decodeIfPresent(String.self, forKey: .releaseDate) {
            // Dates can come in format '6 Apr 1999, 00:00'
            releaseDate = LFMDateFormatter.shared.convert(string: date)
        } else if let date = try container.decodeIfPresent(Date.self, forKey: .releaseDate) {
            // Here we handle decoding already encoded date
            releaseDate = date
        } else {
            releaseDate = nil
        }
    }
    
}

extension LFMAlbum: CustomStringConvertible {
    public var description: String {
        var desc = "\(name)\nurl: \(url)\nimages: \(images.count)"
        if let wiki = wiki {
            desc += "\n\(wiki.content)"
        }
        return desc
    }
}

struct AlbumResponse: Decodable {
    let album: LFMAlbum
}
