//
//  Model.swift
//  QXplayer remote
//
//  Created by Ilya Lagutovsky on 1/15/20.
//  Copyright © 2020 MDSolution. All rights reserved.
//

import Foundation

struct PlayerData: Codable {
    var volume: Float?
    var metaData: MetaData?
    var command: String?
    var currentTime: Float?
    var fileSystem: [File]?
    var currentTrackName: String?
    var pathNewFolder: String?
    
    var json: Data? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return data
    }
}

struct MetaData: Codable {
    var title: String
    var albumName: String
    var artistName: String?
    var albumArt: Data
    var formatName: String?
    var sampleRate: Int?
    var bitRatePerChannel: Int?
    var bitRate: Int?
    var duration: Float?
    var year: String?
}

struct File: Codable {
    var name: String
    var type: TypeFile
    var path: String
}

enum TypeFile: String, Codable {
    case music
    case folder
}
