 
import Foundation

public final class LFM {
    static let shared = LFM()
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
        
    private init() {}
        
    fileprivate class var defaultParams: [String: String] {
        return [
        "api_key": apiKey,
        "lang": language,
        "format": "json"
        ]
    }
    
    fileprivate class var defaultAuthParams: [String: String] {
        var params = [
            "api_key": apiKey
        ]
        if let sk = LFM.Auth.session?.key {
            params["sk"] = sk
        }
        return params
    }
    
    func call<T>(method: LFMMethod, queryParams: [String: String]?, completion: @escaping (Result<T, Error>) -> Void) where T: Decodable {
        guard let request = method.request(with: queryParams) else {
            completion(.failure(LFMError.invalidRequest))
            return
        }
        
        perform(request: request, completion: completion)
    }
    
    func call(method: LFMMethod, queryParams: [String: String]?, completion: ((Error?) -> Void)?) {
        guard let request = method.request(with: queryParams) else {
            completion?(LFMError.invalidRequest)
            return
        }
        
        perform(request: request, completion: completion)
    }
    
    private func perform<T>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) where T: Decodable {
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data, !data.isEmpty else {
                completion(.failure(LFMError.couldNotReadData))
                return
            }
            guard httpResponse.statusCode == 200 else {
                let lfmError = (try? LFMJSONDecoder().decode(LFMError.self, from: data)) ?? LFMError.unknown
                completion(.failure(lfmError))
                return
            }
            do {
                let decoded = try LFMJSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch let decodingError {
                completion(.failure(decodingError))
            }
        }.resume()
    }
    
    private func perform(request: URLRequest, completion: ((Error?) -> Void)?) {
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion?(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data, !data.isEmpty else {
                completion?(LFMError.couldNotReadData)
                return
            }
            if httpResponse.statusCode == 200 {
                completion?(nil)
                return
            }
            do {
                let decoded = try LFMJSONDecoder().decode(LFMError.self, from: data)
                completion?(decoded)
            } catch let decodingError {
                completion?(decodingError)
            }
        }.resume()
    }
}
 
 public extension LFM {
    enum Album {
        public static func getInfo(name: String, artist: String, completion: @escaping (Result<LFMAlbum, Error>) -> Void) {
            
            var params = defaultParams
            params["album"] = name
            params["artist"] = artist
            
            LFM.shared.call(method: Method.album, queryParams: params) { (result: Result<AlbumResponse, Error>) in
                switch result {
                case .success(let response):
                    completion(.success(response.album))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
 }
 
 public extension LFM {
    enum Artist {
        public static func getInfo(name: String, completion: @escaping (Result<LFMArtist, Error>) -> Void) {
            
            var params = defaultParams
            params["artist"] = name
            
            LFM.shared.call(method: Method.artist, queryParams: params) { (result: Result<ArtistResponse, Error>) in
                switch result {
                case .success(let response):
                    completion(.success(response.artist))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
 }
 
 public extension LFM {
    /**
     Module containing methods to call the /track API methods
     */
    enum Track {
        public static func nowPlaying(track name: String, artist: String, album: String?, albumArtist: String?, trackNumber: Int?, duration: TimeInterval?, completion: ((Error?) -> Void)?) {
            
            guard LFM.Auth.session?.isValid == true else {
                LFM.Auth.renewSession { error in
                    if let error = error {
                        completion?(error)
                        return
                    }
                    self.nowPlaying(track: name, artist: artist, album: album, albumArtist: albumArtist, trackNumber: trackNumber, duration: duration, completion: completion)
                }
                return
            }
            
            var params = LFM.defaultAuthParams
            params["track"] = name
            params["artist"] = artist
            params["timestamp"] = String(Int(Date().timeIntervalSince1970))
            if let duration = duration {
                params["duration"] = String(Int(duration))
            }
            
            let method = AuthenticatedMethod.nowPlaying
            params["api_sig"] = method.signed(with: params)
            params["format"] = "json"
            
            LFM.shared.call(method: method, queryParams: params, completion: completion)
        }
        
        public static func scrobble(track name: String, artist: String, album: String?, albumArtist: String?, trackNumber: Int?, duration: TimeInterval?, completion: ((Error?) -> Void)?) {
            
            guard LFM.Auth.session?.isValid == true else {
                LFM.Auth.renewSession { error in
                    if let error = error {
                        completion?(error)
                        return
                    }
                    self.scrobble(track: name, artist: artist, album: album, albumArtist: albumArtist, trackNumber: trackNumber, duration: duration, completion: completion)
                }
                return
            }
            
            var params = defaultAuthParams
            // We have to first add real name and artist so method's signature is correct
            params["track"] = name
            params["artist"] = artist
            params["timestamp"] = String(Int(Date().timeIntervalSince1970))
            if let duration = duration {
                params["duration"] = String(Int(duration))
            }
            
            let method = AuthenticatedMethod.scrobble
            params["api_sig"] = method.signed(with: params)
            params["format"] = "json"
            
            LFM.shared.call(method: method, queryParams: params, completion: completion)
        }
    }
}

private extension LFM {
    enum Method: String, LFMMethod {
        case album = "album.getinfo"
        case artist = "artist.getinfo"
        
        var httpMethod: HTTPMethod {
            switch self {
            case .album, .artist:
                return .get
            }
        }
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
        
        var httpMethod: HTTPMethod {
            switch self {
            case .nowPlaying, .scrobble:
                return .post
            }
        }
    }
}
