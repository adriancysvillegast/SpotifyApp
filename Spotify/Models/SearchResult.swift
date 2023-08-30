//
//  SearchResult.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 20/8/23.
//

import Foundation

enum SearchResult {
    case artist(model: ArtistsResponse)
    case album(model: AlbumResponse)
    case track(model: AudioTrack)
    case playlist(model: Playlist)
}
