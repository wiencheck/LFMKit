//
//  File.swift
//  
//
//  Created by Adam Wienconek on 20/06/2022.
//

import Foundation

public extension LFM {
    /**
     Module containing methods to call the /track API methods
     */
    enum Track {
        public static func updateNowPlaying(trackNamed name: String, artist: String, album: String?, albumArtist: String?, trackNumber: Int?, duration: TimeInterval?, completion: ((Error?) -> Void)?) {
            var params = LFM.defaultAuthParams
            
            params["track"] = name
            params["artist"] = artist
            if let duration = duration {
                params["duration"] = String(Int(duration))
            }
            
            let method = Method.nowPlaying
            params["api_sig"] = method.signed(with: params)
            params["format"] = "json"
            
            LFM.call(method: method, queryParams: params, completion: completion)
        }
        
        public static func scrobble(trackNamed name: String,
                                    artist: String,
                                    album: String?,
                                    albumArtist: String?,
                                    trackNumber: Int?,
                                    duration: TimeInterval?,
                                    timestamp: Date,
                                    completion: ((Error?) -> Void)?) {
            guard LFM.Auth.session?.isValid == true else {
                LFM.Auth.renewSession { error in
                    if let error = error {
                        completion?(error)
                        return
                    }
                    self.scrobble(trackNamed: name,
                                  artist: artist,
                                  album: album,
                                  albumArtist: albumArtist,
                                  trackNumber: trackNumber,
                                  duration: duration,
                                  timestamp: timestamp,
                                  completion: completion)
                }
                return
            }
            var params = LFM.defaultAuthParams
            
            // We have to first add real name and artist so method's signature is correct
            params["track"] = name
            params["artist"] = artist
            params["album"] = album
            params["albumArtist"] = albumArtist
            params["timestamp"] = String(Int(timestamp.timeIntervalSince1970))
            if let duration = duration {
                params["duration"] = String(Int(duration))
            }
            
            let method = Method.scrobble
            params["api_sig"] = method.signed(with: params)
            params["format"] = "json"
            
            LFM.call(method: method, queryParams: params, completion: completion)
        }
        
        public static func scrobble<T>(_ scrobbles: T, completion: ((Error?) -> Void)?) where T: Collection, T.Element == Scrobble {
            guard scrobbles.count <= 50 else {
                completion?(ScrobblesCountExceededError())
                return
            }
            var params = LFM.defaultAuthParams
            
            for (idx, scrobble) in scrobbles.enumerated() {
                params["track[\(idx)]"] = scrobble.name
                params["artist[\(idx)]"] = scrobble.artist
                params["album[\(idx)]"] = scrobble.album
                params["albumArtist[\(idx)]"] = scrobble.albumArtist
                params["timestamp[\(idx)]"] = String(Int(scrobble.timestamp.timeIntervalSince1970))
                if let duration = scrobble.duration {
                    params["duration[\(idx)]"] = String(Int(duration))
                }
            }
            let method = Method.scrobble
            params["api_sig"] = method.signed(with: params)
            params["format"] = "json"
            
            LFM.call(method: method, queryParams: params, completion: completion)
        }
        
    }
    
    private enum Method: String, LFMAuthenticatedMethod {
        case nowPlaying = "track.updateNowPlaying"
        case scrobble = "track.scrobble"
        
        var httpMethod: HTTPMethod {
            switch self {
            case .nowPlaying, .scrobble:
                return .post
            }
        }
    }
    
}

public struct ScrobblesCountExceededError: LocalizedError {
    public var errorDescription: String? {
        "You cannot send more than 50 scrobbles at once."
    }
}

// MARK: Async/await support
@available(iOS 13.0, *)
extension LFM.Track {
    
    public static func updateNowPlaying(trackNamed name: String, artist: String, album: String?, albumArtist: String?, trackNumber: Int?, duration: TimeInterval?) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            self.updateNowPlaying(trackNamed: name,
                                  artist: artist,
                                  album: album,
                                  albumArtist: albumArtist,
                                  trackNumber: trackNumber,
                                  duration: duration,
                                  completion: { error in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                else {
                    continuation.resume()
                }
            })
        }
    }
    
    public static func scrobble(trackNamed name: String,
                                artist: String,
                                album: String?,
                                albumArtist: String?,
                                trackNumber: Int?,
                                duration: TimeInterval?,
                                timestamp: Date) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            self.scrobble(trackNamed: name,
                          artist: artist,
                          album: album,
                          albumArtist: albumArtist,
                          trackNumber: trackNumber,
                          duration: duration,
                          timestamp: timestamp,
                          completion: { error in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                else {
                    continuation.resume()
                }
            })
        }
    }
    
    public static func scrobble<T>(_ scrobbles: T) async throws where T: Collection, T.Element == Scrobble {
        return try await withCheckedThrowingContinuation { continuation in
            self.scrobble(scrobbles,
                          completion: { error in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                else {
                    continuation.resume()
                }
            })
        }
    }

}
