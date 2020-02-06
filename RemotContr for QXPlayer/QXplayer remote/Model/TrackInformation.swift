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
        
        if currentTrack.trackName == tracksInformation[tracksInformation.count - 1].trackName {
            return nil
        } else {
            var i = 0
            for trackInfo in tracksInformation {
                if currentTrack.trackName == trackInfo.trackName {
                    currentTrack = tracksInformation[i + 1]
                    return currentTrack
                }
                i = i + 1
            }
        }
        return nil
    }
    
    mutating func prevTrack() -> TrackInformation? {
        
        if currentTrack.trackName == tracksInformation[0].trackName {
            return nil
        } else {
            var i = 0
            for trackInfo in tracksInformation {
                if currentTrack.trackName == trackInfo.trackName {
                    currentTrack = tracksInformation[i - 1]
                    return currentTrack
                }
                i = i + 1
            }
        }
        return nil
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
