//
//  File.swift
//  
//
//  Created by Adam Wienconek on 01/09/2020.
//

import Foundation
import Combine

public extension LFM {
    
    enum Auth {
        private static let sessionUserDefaultsKey = "LFMSessionUserDefaultsKey"
        
        @available(iOS 13.0, *)
        private static var sessionUpdatedSubject: PassthroughSubject<Session?, Never> = .init()
        
        public private(set) static var session: Session? {
            get {
                guard let data = UserDefaults.standard.data(forKey: Auth.sessionUserDefaultsKey),
                    let decoded = try? JSONDecoder().decode(Session.self, from: data) else {
                        return nil
                }
                return decoded
            } set {
                defer {
                    if #available(iOS 13.0, *) {
                        sessionUpdatedSubject.send(newValue)
                    }
                }
                guard let newValue = newValue,
                    let data = try? JSONEncoder().encode(newValue) else {
                        UserDefaults.standard.removeObject(forKey: Auth.sessionUserDefaultsKey)
                        return
                }
                UserDefaults.standard.set(data, forKey: Auth.sessionUserDefaultsKey)
            }
        }
        
        @available(iOS 13.0, *)
        public static var sessionUpdatedPublisher: AnyPublisher<Session?, Never> {
            sessionUpdatedSubject.eraseToAnyPublisher()
        }
        
        public static func renewSession(completion: ((Error?) -> Void)?) {
            if session == nil {
                completion?(LastFMInvalidSessionError())
                return
            }
            
            token { result in
                switch result {
                case .success(let token):
                    self.session?.token = token
                    completion?(nil)
                case .failure(let error):
                    completion?(error)
                }
            }
        }
        
        public static func removeSession() {
            session = nil
        }
        
        private static func token(completion: @escaping (Result<String, Error>) -> Void) {
            guard !LFM.apiKey.isEmpty else {
                completion(.failure(LastFMInvalidSessionError()))
                return
            }
            let params = [
                "api_key": LFM.apiKey,
                "format": "json"
            ]
            
            LFM.call(method: Method.token, queryParams: params) { (result: Result<TokenResponse, Error>) in
                switch result {
                case .success(let response):
                    completion(.success(response.token))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        public static func authenticate(username: String, password: String, completion: @escaping (Result<Session, Error>) -> Void) {
            guard !LFM.apiKey.isEmpty && !LFM.apiSecret.isEmpty else {
                completion(.failure(LastFMInvalidAPICredentialsError()))
                return
            }
            
            func updateSession(with token: String) {
                var params = [
                    "username": username,
                    "password": password,
                    "api_key": LFM.apiKey
                ]
                
                let method = AuthenticatedMethod.session
                params["api_sig"] = method.signed(with: params)
                // Default format is XML but we want Jason!
                params["format"] = "json"
                
                LFM.call(method: method, queryParams: params) { (result: Result<SessionResponse, Error>) in
                    switch result {
                    case .success(let response):
                        var newSession = response.session
                        newSession.token = token
                        self.session = newSession
                        completion(.success(newSession))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
            // Get token
            token { result in
                switch result {
                case .success(let token):
                    // Session does not need updating
                    if var session = self.session {
                        session.token = token
                        self.session = session
                        completion(.success(session))
                        return
                    }
                    updateSession(with: token)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        public static func signOut() {
            session = nil
        }
    }
    
}

@available(iOS 13.0, *)
extension LFM.Auth {
    
    public static func renewSession() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            self.renewSession { error in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                else {
                    continuation.resume()
                }
            }
        }
    }

}

extension LFM.Auth {
    
    enum Method: String, LFMMethod {
        /**
         Parameters for this method are:
         -  api_key
         -  api_sig
         */
        case token = "auth.gettoken"
        
        var httpMethod: HTTPMethod {
            return .get
        }
    }
    
    enum AuthenticatedMethod: String, LFMAuthenticatedMethod {
        /**
         Parameters for this method are:
         -  password
         -  username
         -  api_key
         -  api_sig
         */
        case session = "auth.getMobileSession"
        
        var httpMethod: HTTPMethod {
            return .post
        }
    }
    
}

public struct LastFMInvalidSessionError: Error {
    
}

public struct LastFMInvalidAPICredentialsError: Error {
    
}
