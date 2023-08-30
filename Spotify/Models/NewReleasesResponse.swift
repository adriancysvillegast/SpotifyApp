//
//  ReleasesModel.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 1/8/23.
//

import Foundation

struct NewReleasesResponse: Codable {
    let albums: AlbumsResponse
}

// MARK: - Albums
struct AlbumsResponse: Codable {
    let items: [AlbumResponse]
}

// MARK: - AlbumResponse
struct AlbumResponse: Codable {

    let albumType: String
    let availableMarkets: [String]
    let id: String
    var images: [APIImage]
    let name: String
    let releaseDate: String
    let totalTracks: Int
    let artists: [ArtistsResponse]
}



