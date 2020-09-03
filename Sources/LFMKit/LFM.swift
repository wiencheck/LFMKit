 
import Foundation
import Alamofire

public final class LFM {
    
    /**
     Your API key obtained from Last.fm.
     */
    public static var apiKey = ""
    
    /**
     Your secret key obtained from Last.fm.
     Secret is used for calls requiring authentication, like `scrobble`, or `updateNowPlaying`.
     */
    public static var apiSecret = ""
        
    /**
     Requested language of `getInfo` calls.
     */
    public static var language = "en"
        
    fileprivate class var defaultParams: [String: Any] {
        return [
        "api_key": apiKey,
        "lang": language,
        "format": "json"
        ]
    }
    
    fileprivate class var defaultAuthParams: [String: Any] {
        var params = [
            "api_key": apiKey
        ]
        if let sk = auth.session?.key {
            params["sk"] = sk
        }
        return params
    }
    
    public static let auth = Auth()
    
}
 
 public extension LFM {
    enum album {
        public static func getInfo(name: String, artist: String, success: @escaping (LFMAlbum) -> Void, failure: ((Error) -> Void)? = nil) {
            // Use lowercased strings to avoid unexpected issues later.
            let _name = name.lowercased()
            let _artist = artist.lowercased()
            
            guard let url = composeUrl(album: _name, artist: _artist) else {
                print("*** Couldn't create valid url for the album.")
                return
            }
            
            Alamofire.request(url).responseData { response in
                if let error = response.error {
                    failure?(error)
                }
                guard let data = response.value else {
                    return
                }
                if let error = try? JSONDecoder().decode(LFMError.self, from: data) {
                    failure?(error)
                } else if let albumResponse = try? JSONDecoder().decode(AlbumResponse.self, from: data) {
                    let album = albumResponse.album
                    success(album)
                }
            }
        }
    }
 }
 
 public extension LFM {
    enum artist {
        public static func getInfo(name: String, success: @escaping (LFMArtist) -> Void, failure: ((Error) -> Void)? = nil) {
            // Use lowercased strings to avoid unexpected issues later.
            let _name = name.lowercased()
            
            guard let url = composeUrl(artist: _name) else {
                print("*** Couldn't create valid url for the artist.")
                return
            }
            
            Alamofire.request(url).responseData { response in
                if let error = response.error {
                    failure?(error)
                }
                guard let data = response.value else {
                    return
                }
                if let error = try? JSONDecoder().decode(LFMError.self, from: data) {
                    failure?(error)
                } else if let artistResponse = try? JSONDecoder().decode(ArtistResponse.self, from: data) {
                    let artist = artistResponse.artist
                    success(artist)
                }
            }
        }
    }
 }
 
 public extension LFM {
    enum track {
        public static func nowPlaying(track name: String, artist: String, album: String?, albumArtist: String?, trackNumber: Int?, duration: TimeInterval?, success: (() -> Void)? = nil, failure: ((Error) -> Void)? = nil) {
            
            guard auth.session?.isValid == true else {
                auth.renewSession(success: {
                    self.nowPlaying(track: name, artist: artist, album: album, albumArtist: albumArtist, trackNumber: trackNumber, duration: duration, success: success, failure: failure)
                }, failure: failure)
                return
            }
            
            var params = LFM.defaultAuthParams
            params["track"] = name
            params["artist"] = artist
            params["timestamp"] = Int(Date().timeIntervalSince1970)
            if let duration = duration {
                params["duration"] = Int(duration)
            }
            
            let method = AuthenticatedMethod.nowPlaying
            params["api_sig"] = method.signed(with: params)
            params["format"] = "json"
            params["track"] = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
            params["artist"] = artist.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? artist
            
            guard let url = method.composed(with: params) else {
                return
            }
            Alamofire.request(url, method: .post).responseData { response in
                if let error = response.error {
                    failure?(error)
                }
                guard let data = response.value else {
                    return
                }
                if let error = try? JSONDecoder().decode(LFMError.self, from: data) {
                    failure?(error)
                } else {
                    success?()
                }
            }
        }
        
        public static func scrobble(track name: String, artist: String, album: String?, albumArtist: String?, trackNumber: Int?, duration: TimeInterval?, success: (() -> Void)? = nil, failure: ((Error) -> Void)? = nil) {
            
            guard auth.session?.isValid == true else {
                auth.renewSession(success: {
                    self.scrobble(track: name, artist: artist, album: album, albumArtist: albumArtist, trackNumber: trackNumber, duration: duration, success: success, failure: failure)
                }, failure: failure)
                return
            }
            
            var params = defaultAuthParams
            // We have to first add real name and artist so method's signature is correct
            params["track"] = name
            params["artist"] = artist
            params["timestamp"] = Int(Date().timeIntervalSince1970)
            if let duration = duration {
                params["duration"] = Int(duration)
            }
            
            let method = AuthenticatedMethod.scrobble
            params["api_sig"] = method.signed(with: params)
            params["format"] = "json"
            // Replace them with correctly encoded values for the real url
            params["track"] = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
            params["artist"] = artist.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? artist
            
            guard let url = method.composed(with: params) else {
                return
            }
            Alamofire.request(url, method: .post).responseData { response in
                if let error = response.error {
                    failure?(error)
                }
                guard let data = response.value else {
                    return
                }
                if let error = try? JSONDecoder().decode(LFMError.self, from: data) {
                    failure?(error)
                } else {
                    success?()
                }
            }
        }
    }
 }

// MARK: Private methods
private extension LFM {
    class func composeUrl(album name: String, artist: String) -> URL? {
        guard !LFM.apiKey.isEmpty else {
            print("*** 'clientKey' cannot be empty")
            return nil
        }
        var params = defaultParams
        params["album"] = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        params["artist"] = artist.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? artist
        
        return Method.album.composed(with: params)
    }
    
    class func composeUrl(artist name: String) -> URL? {
        guard !LFM.apiKey.isEmpty else {
            print("*** 'clientKey' cannot be empty")
            return nil
        }
        var params = defaultParams
        params["artist"] = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        
        return Method.artist.composed(with: params)
    }
}

private extension LFM {
    enum Method: String, LFMMethod {
        case album = "album.getinfo"
        case artist = "artist.getinfo"
    }
    
    enum AuthenticatedMethod: String, LFMAuthenticatedMethod {
        /**
         Parameters for this method are:
         - artist[i] (Required) : The artist name.
         - track[i] (Required) : The track name.
         - timestamp[i] (Required) : The time the track started playing, in UNIX timestamp format (integer number of seconds since 00:00:00, January 1st 1970 UTC). This must be in the UTC time zone.
         - album[i] (Optional) : The album name.
         - trackNumber[i] (Optional) : The track number of the track on the album.
         - albumArtist[i] (Optional) : The album artist - if this differs from the track artist.
         - duration[i] (Optional) : The length of the track in seconds.
         - api_key (Required) : A Last.fm API key.
         - api_sig (Required) : A Last.fm method signature. See authentication for more information.
         - sk (Required) : A session key generated by authenticating a user via the authentication protocol.
         */
        case nowPlaying = "track.updateNowPlaying"
        
        /**
        Parameters for this method are:
         - artist[i] (Required) : The artist name.
         - track[i] (Required) : The track name.
         - timestamp[i] (Required) : The time the track started playing, in UNIX timestamp format (integer number of seconds since 00:00:00, January 1st 1970 UTC). This must be in the UTC time zone.
         - album[i] (Optional) : The album name.
         - trackNumber[i] (Optional) : The track number of the track on the album.
         - albumArtist[i] (Optional) : The album artist - if this differs from the track artist.
         - duration[i] (Optional) : The length of the track in seconds.
         - api_key (Required) : A Last.fm API key.
         - api_sig (Required) : A Last.fm method signature. See authentication for more information.
         - sk (Required) : A session key generated by authenticating a user via the authentication protocol.
         */
        case scrobble = "track.scrobble"
    }
    
    enum UserDefaultsKey: String {
        case albums = "LFMSavedAlbums"
        case artists = "LFMSavedArtists"
    }
}
