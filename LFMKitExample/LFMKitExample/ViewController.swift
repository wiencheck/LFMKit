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

        LFM.apiKey =
        /// Secret is used for calls requiring authentication, like `scrobble`, or `updateNowPlaying`
        LFM.apiSecret =
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        LFM.artist.getInfo(name: "tame impala", success: { artist in
            print(artist)
        })
        
        LFM.album.getInfo(name: "currents", artist: "tame impala", success: { album in
            print(album)
        })
        
        LFM.track.scrobble(track: "Elephant", artist: "Tame Impala", album: "Lonerism", albumArtist: nil, trackNumber: nil, duration: nil, success: {
            print("Scrobbled!")
        }, failure: { error in
            print("Couldn't scrobble, error: ", error.localizedDescription)
        })
    }
}

