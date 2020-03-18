//
//  ReceivingDataManager.swift
//  QXplayer remote
//
//  Created by Ilya Lagutovsky on 3/13/20.
//  Copyright © 2020 MDSolution. All rights reserved.
//

import Foundation
import UIKit

protocol ReceivingData {
     func cameData(from notification: Notification)
     func changeTheNumberOfDevice(navigationController: UINavigationController?)
}

class ReceivingDataManager: ReceivingData {
    
    private lazy var appDelegate = AppDelegate.shared()
    private var playerManager: PlayerManager
   
    init(currentViewController: PlayerDataActionsDelegate) {
        self.playerManager = PlayerManager()
        self.playerManager.delegate = currentViewController
    }
    
    func cameData(from notification: Notification) {
        if let data = notification.userInfo?["data"] as? Data {
            playerManager.handleData(data: data)
        }
    }
    
    func changeTheNumberOfDevice(navigationController: UINavigationController?) {
        guard let navigationController = navigationController else { return }
        
        if let devices = appDelegate.bonjourServer.devices {
            devices.forEach { (device) in
                if appDelegate.bonjourServer.connectToServer(device) {
                    return
                }
            }
            navigationController.popViewController(animated: true)
            if let vc = navigationController.topViewController as? DevicesListViewController {
                vc.listTableView.reloadData()
                appDelegate.bonjourServer = BonjourServer()
            }
            
            navigationController.navigationBar.isHidden = false
        }
    }
    
}
