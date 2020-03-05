//
//  Model.swift
//  QXplayer remote
//
//  Created by Ilya Lagutovsky on 1/15/20.
//  Copyright © 2020 MDSolution. All rights reserved.
//

import Foundation

//struct TrackList: Codable {
//    var tracksInformation: [TrackInformation]
//    var currentTrack: TrackInformation
//
//    mutating func nextTrack() -> TrackInformation? {
//        if currentTrack.trackName == tracksInformation.last?.trackName {
//            return nil
//        } else {
//            guard let currentIndex = tracksInformation.firstIndex(where: { $0.trackName == currentTrack.trackName }) else { return nil }
//            currentTrack = tracksInformation[currentIndex + 1]
//            return currentTrack
//        }
//    }
//
//    mutating func prevTrack() -> TrackInformation? {
//        if currentTrack.trackName == tracksInformation.first?.trackName {
//            return nil
//        } else {
//            guard let currentIndex = tracksInformation.firstIndex(where: { $0.trackName == currentTrack.trackName }) else { return nil }
//            currentTrack = tracksInformation[currentIndex - 1]
//            return currentTrack
//        }
//    }
//
//    func searchTrack(byTrackName trackName: String) -> TrackInformation? {
//        return tracksInformation.first { $0.trackName == trackName }
//    }
//}

struct PlayerData: Codable {
    var volume: Float?
    var metaData: MetaData?
    var command: String?
    var currentTime: Float?
    var playerFileSystem: PlayerFileSystem?
    var currentTrackName: String?
    
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

struct PlayerFileSystem: Codable {
    var trackList: [String]?
    var titleMainFolder: String
    var titlePreviousFolder: String?
    var otherFolders: [String]?
}
