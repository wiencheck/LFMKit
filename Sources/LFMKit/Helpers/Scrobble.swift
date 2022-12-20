//
//  File.swift
//  
//
//  Created by Adam Wienconek on 20/06/2022.
//

import Foundation

public struct Scrobble: Codable {
    
    /// The track name.
    public var name: String
    
    /// The artist name.
    public var artist: String
    
    /// The artist name.
    public var album: String?
    
    /// The album artist - if this differs from the track artist.
    public var albumArtist: String?
    
    /// The track number of the track on the album.
    public var trackNumber: Int?
    
    /// The length of the track in seconds.
    public var duration: TimeInterval?
    
    /// The date the track started playing.
    ///
    /// Default value is the date of creating the scrobble instance.
    public var timestamp: Date
    
    public init(name: String, artist: String, album: String? = nil, albumArtist: String? = nil, trackNumber: Int? = nil, duration: TimeInterval? = nil, timestamp: Date = .init()) {
        self.name = name
        self.artist = artist
        self.album = album
        if albumArtist != artist {
            self.albumArtist = albumArtist
        }
        self.trackNumber = trackNumber
        self.duration = duration
        self.timestamp = timestamp
    }
    
    
}
