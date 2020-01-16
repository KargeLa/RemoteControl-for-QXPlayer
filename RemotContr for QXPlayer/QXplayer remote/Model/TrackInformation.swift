//
//  Model.swift
//  QXplayer remote
//
//  Created by Ilya Lagutovsky on 1/15/20.
//  Copyright © 2020 MDSolution. All rights reserved.
//

import Foundation


struct TrackInformation: Codable {
    var trackName: String
    var albumName: String
    var imageData: Data
}
