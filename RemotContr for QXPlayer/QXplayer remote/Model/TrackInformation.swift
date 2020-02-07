//
//  Model.swift
//  QXplayer remote
//
//  Created by Ilya Lagutovsky on 1/15/20.
//  Copyright © 2020 MDSolution. All rights reserved.
//

import Foundation

struct TrackList: Codable {
    var tracksInformation: [TrackInformation]
    var currentTrack: TrackInformation
    
    mutating func nextTrack() -> TrackInformation? {
        if currentTrack.trackName == tracksInformation.last?.trackName {
            return nil
        } else {
            guard let currentIndex = tracksInformation.firstIndex(where: { $0.trackName == currentTrack.trackName }) else { return nil }
            currentTrack = tracksInformation[currentIndex + 1]
            return currentTrack
        }
    }
    
    mutating func prevTrack() -> TrackInformation? {
        if currentTrack.trackName == tracksInformation.first?.trackName {
            return nil
        } else {
            guard let currentIndex = tracksInformation.firstIndex(where: { $0.trackName == currentTrack.trackName }) else { return nil }
            currentTrack = tracksInformation[currentIndex - 1]
            return currentTrack
        }
    }
    
    func searchTrack(byTrackName trackName: String) -> TrackInformation? {
        return tracksInformation.first { $0.trackName == trackName }
    }
}

struct TrackInformation: Codable {
    var trackName: String
    var albumName: String
    var imageData: Data
}
