//
//  AuthResponse.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 23/7/23.
//

import Foundation

struct AuthResponse: Codable {
    let accessToken : String
    let expiresIn: Int
    let refreshToken: String?
    let scope: String
    let tokenType: String
}
