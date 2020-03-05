//
//  DataReception.swift
//  QXplayer remote
//
//  Created by Ilya Lagutovsky on 2/28/20.
//  Copyright © 2020 MDSolution. All rights reserved.
//

import Foundation

protocol PlayerDataActionsDelegate: class {
    func dataAction(volume: Float)
    func dataAction(metaData: MetaData)
    func dataAction(command: String)
    func dataAction(currentTime: Float)
    func dataAction(listTrack: [String])
}

class PlayerManager {
    weak var delegate: PlayerDataActionsDelegate?
    
    func handleData(data: Data) {
        guard let playerData = try? JSONDecoder().decode(PlayerData.self, from: data) else { return }
        
        if let volume = playerData.volume {
            delegate?.dataAction(volume: volume)
        }
        if let metaData = playerData.metaData {
            delegate?.dataAction(metaData: metaData)
        }
        if let command = playerData.command {
            delegate?.dataAction(command: command)
        }
        if let currentTime = playerData.currentTime {
            delegate?.dataAction(currentTime: currentTime)
        }
        if let listTrack = playerData.listTrack {
            delegate?.dataAction(listTrack: listTrack)
        }
    }
}
