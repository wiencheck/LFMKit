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
    
    public let url: URL
    
    public let releaseDate: Date?
    
    public let images: [LFMImage]

    public let wiki: Wiki?
    
    private enum CodingKeys: String, CodingKey {
        case name, artist, url, wiki
        case releaseDate = "releasedate"
        case images = "image"
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
