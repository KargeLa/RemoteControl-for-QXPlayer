//
//  DataManager.swift
//  QXplayer remote
//
//  Created by Алексей Смоляк on 2/27/20.
//  Copyright © 2020 MDSolution. All rights reserved.
//

import Foundation

enum ActionType: Int {
    case play/*0*/, pause/*1*/, next/*2*/, prev/*3*//*, trackList/*4*/*/
}

struct Package: Decodable {
    var currentTime: Int?
    var currentVolume: Float?
    var action: Int?
//    var trackList: TrackList?
}

