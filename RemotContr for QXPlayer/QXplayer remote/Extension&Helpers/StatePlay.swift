//
//  StatePlay.swift
//  QXplayer remote
//
//  Created by Ilya Lagutovsky on 2/6/20.
//  Copyright © 2020 MDSolution. All rights reserved.
//

import Foundation

enum StatePlay: String {
    case playningMusic
    case notPlayningMusic
    
    var opposite: StatePlay {
        switch self {
        case .playningMusic:
            return .notPlayningMusic
        case .notPlayningMusic:
            return .playningMusic
        }
    }
}
