//
//  LibraryAlbumsResponse.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 29/8/23.
//

import Foundation

struct LibraryAlbumsResponse: Codable {
    let items: [SavedAlbumResponse]
}

struct SavedAlbumResponse: Codable {
    let addedAt: String
    let album: AlbumResponse
}
