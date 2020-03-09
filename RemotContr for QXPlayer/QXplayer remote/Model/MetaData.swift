//
//  DataManager.swift
//  QXplayer remote
//
//  Created by Алексей Смоляк on 2/27/20.
//  Copyright © 2020 MDSolution. All rights reserved.
//

import Foundation

enum ActionType: Int {
    case connect, play, pause, next, prev, volume, time, changedTrack
}

struct MetaData: Codable {
    var title: String
    var albumName: String
    var albumArt: Data
}

struct PlayerManager: Codable {
    var nameOfTracks: [String]?
    var currentTrack: MetaData?
    var action: Int?
    var maxCurrentTime: Int?
    var currentTime: Int?
    var currentVolume: Float?
    var currentTrackName: String?
    
    var json: Data? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return data
    }
}
