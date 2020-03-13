//
//  SendDataManager.swift
//  QXplayer remote
//
//  Created by Ilya Lagutovsky on 3/13/20.
//  Copyright © 2020 MDSolution. All rights reserved.
//

import Foundation

protocol SendData {
    func sendDataToComputerPlayer(volume: Float?,
                                  command: String?,
                                  currentTime: Float?,
                                  currentTrackName: String?,
                                  nameFolder: String?)
}

extension SendData {
    func sendDataToComputerPlayer(volume: Float? = nil,
                                  command: String? = nil ,
                                  currentTime: Float? = nil,
                                  currentTrackName: String? = nil,
                                  nameFolder: String? = nil) {
        return sendDataToComputerPlayer(volume: volume, command: command, currentTime: currentTime, currentTrackName: currentTrackName, nameFolder: nameFolder)
    }
}

    

class SendDataManager: SendData {
    private lazy var appDelegate = AppDelegate.shared()
    
    func sendDataToComputerPlayer(volume: Float? = nil, command: String? = nil, currentTime: Float? = nil, currentTrackName: String? = nil, nameFolder: String? = nil) {
        
        let playerData = PlayerData(volume: volume, command: command, currentTime: currentTime, currentTrackName: currentTrackName, pathNewFolder: nameFolder)
        
        guard let data = playerData.json else { return }
        appDelegate.bonjourServer.send(data)
    }
}
