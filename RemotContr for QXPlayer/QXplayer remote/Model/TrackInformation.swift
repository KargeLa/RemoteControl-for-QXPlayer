//
//  Model.swift
//  QXplayer remote
//
//  Created by Ilya Lagutovsky on 1/15/20.
//  Copyright © 2020 MDSolution. All rights reserved.
//

import Foundation


struct TrackInformation: Codable {
    var nameTrack: String
    var nameAlbum: String
    var imageData: Data
}
