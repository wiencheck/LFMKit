//
//  File.swift
//  
//
//  Created by Adam Wienconek on 01/09/2020.
//

import Foundation

public struct LFMArtist: Codable {
    public let name: String
        
    public let url: URL
        
    public let images: [LFMImage]

    public let wiki: Wiki?
    
    private enum CodingKeys: String, CodingKey {
        case name, url
        case wiki = "bio"
        case images = "image"
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
