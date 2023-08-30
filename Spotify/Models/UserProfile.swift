//
//  UserProfile.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 22/7/23.
//

import Foundation

struct UserProfile: Codable {
    let country, displayName, email: String
    let id: String
    let explicitContent: [String: Bool]
    let externalUrls: [String: String]
    let images: [APIImage]
    let product, type, uri: String
}

