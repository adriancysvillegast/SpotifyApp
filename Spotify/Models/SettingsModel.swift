//
//  SettingsModel.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 25/7/23.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handler: () -> Void
}
