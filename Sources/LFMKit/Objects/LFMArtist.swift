//
//  File.swift
//  
//
//  Created by Adam Wienconek on 01/09/2020.
//

import Foundation

public struct LFMArtist: Codable {
    public let name: String
        
    public let url: String
        
    public let images: [LFMImage]

    private let wiki: Wiki?
    
    public var summary: String? {
        return wiki?.content
    }
    
    private enum CodingKeys: String, CodingKey {
        case name, url
        case wiki = "bio"
        case images = "image"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        url = try container.decode(String.self, forKey: .url)
        images = try container.decode([LFMImage].self, forKey: .images)
        wiki = try container.decodeIfPresent(Wiki.self, forKey: .wiki)
    }
    
}

extension LFMArtist: CustomStringConvertible {
    public var description: String {
        var desc = "\(name)\nurl: \(url)\nimages: \(images.count)"
        if let wiki = wiki {
            desc += "\n\(wiki.content)"
        }
        return desc
    }
}

struct ArtistResponse: Decodable {
    let artist: LFMArtist
}
