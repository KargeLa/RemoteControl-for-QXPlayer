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
    var currentTrack: TrackInformation?
    
    mutating func nextTrack() -> TrackInformation? {
        
        guard let currentTrack = currentTrack else { return nil }
        
        
        if currentTrack.trackName == tracksInformation[tracksInformation.count - 1].trackName {
            return nil
        } else {
            var i = 0
            for trackInfo in tracksInformation {
                if currentTrack.trackName == trackInfo.trackName {
                    self.currentTrack = tracksInformation[i + 1]
                    return tracksInformation[i + 1]
                }
                i = i + 1
            }
        }
        return nil
    }
    
    mutating func prevTrack() -> TrackInformation? {
        
        guard let currentTrack = currentTrack else { return nil }
        
        if currentTrack.trackName == tracksInformation[0].trackName {
            return nil
        } else {
            var i = 0
            for trackInfo in tracksInformation {
                if currentTrack.trackName == trackInfo.trackName {
                    self.currentTrack = tracksInformation[i - 1]
                    return tracksInformation[i - 1]
                }
                i = i + 1
            }
        }
        return nil
    }
}

struct TrackInformation: Codable {
    var trackName: String
    var albumName: String
    var imageData: Data
}
