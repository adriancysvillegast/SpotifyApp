//
//  PlaylistDetailResponse.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 11/8/23.
//

import Foundation


struct PlaylistDetailResponse: Codable {
    let description: String
    let externalUrls: [String: String]
    let id: String
    let images: [APIImage]
    let name: String
    let owner: User
    let tracks: PlaylistTracksResponse
}

struct PlaylistTracksResponse: Codable {
    let items: [PlaylistItem]
}

struct PlaylistItem: Codable {
    let track: AudioTrack
}
