//
//  Playlist.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 22/7/23.
//

import Foundation

struct Playlist: Codable {
    let name: String
    let description: String
    let externalUrls: [String: String]
    let id: String
    let images: [APIImage]
    let owner: User
}
