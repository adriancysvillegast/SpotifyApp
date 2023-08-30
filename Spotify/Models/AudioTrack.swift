//
//  AudioTrack.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 22/7/23.
//

import Foundation

struct AudioTrack: Codable {
    var album: AlbumResponse?
    let artists: [ArtistsResponse]
    let availableMarkets: [String]
    let discNumber: Int
    let durationMs: Int
    let explicit: Bool
    let externalUrls: [String: String]
    let id: String
    let name: String
    let previewUrl: String?
}

