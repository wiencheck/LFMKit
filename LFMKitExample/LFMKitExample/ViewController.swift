//
//  ViewController.swift
//  LFMKitExample
//
//  Created by Adam Wienconek on 01/09/2020.
//  Copyright © 2020 Adam Wienconek. All rights reserved.
//

import UIKit
import LFMKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        LFM.apiKey = <#apiKey#>
        /// Secret is used for calls requiring authentication, like `scrobble`, or `updateNowPlaying`
        LFM.apiSecret = <#apiSecret#>
        
        LFM.auth.authenticate(username: <#String#>, password: <#String#>, success: { session in
            print(session.name)
        }, failure: { error in
            /// This error is `LFMError`. If its code equals 0, it was created by framework and indicates an error with logic somewhere in code and should not be presented to user.
            print(error.localizedDescription)
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        LFM.artist.getInfo(name: "sly & the family stone", success: { artist in
            print(artist.wiki?.summary)
        })

        LFM.album.getInfo(name: "currents", artist: "tame impala", success: { album in
            print(album)
        })
        
        // Session must be valid for this method
        LFM.track.scrobble(track: "Elephant", artist: "Tame Impala", album: "Lonerism", albumArtist: nil, trackNumber: nil, duration: nil, success: {
            print("Scrobbled!")
        }, failure: { error in
            print("Couldn't scrobble, error: ", error.localizedDescription)
        })
    }
}

