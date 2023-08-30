//
//  FeaturedPlaylistResponse.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 3/8/23.
//

import Foundation

struct FeaturedPlaylistResponse: Codable {
    let playlists: PlaylistsResponse
}

struct CategoryPlaylistResponse: Codable {
    let playlists: PlaylistsResponse
}

struct PlaylistsResponse: Codable {
    let items : [Playlist]
}

struct User: Codable {
    let displayName: String
    let externalUrls: [String: String]
    let id: String
}
