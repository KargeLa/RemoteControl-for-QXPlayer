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
    func subscribeToReceiveData(signedController: PlayerDataActionsDelegate, navigationVC: UINavigationController)
}

class ReceivingDataManager: ReceivingData {
    
    private lazy var appDelegate = AppDelegate.shared()
    private let playerManager = PlayerManager()
    private var navigationController: UINavigationController?
    
    func subscribeToReceiveData(signedController: PlayerDataActionsDelegate, navigationVC: UINavigationController) {
        playerManager.delegate = signedController
        navigationController = navigationVC
        NotificationCenter.default.addObserver(self, selector: #selector(dataCameFromTheServer(_: )), name: .dataCameFromTheServer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changedTheNumberOfDevices(_: )), name: .changedTheNumberOfDevices, object: nil)
    }
    
    @objc private func dataCameFromTheServer(_ notification: Notification) {
        if let data = notification.userInfo?["data"] as? Data {
            playerManager.handleData(data: data)
        }
    }
    
    @objc private func changedTheNumberOfDevices(_ notification: Notification) {
        if let devices = appDelegate.bonjourServer.devices {
            devices.forEach { (device) in
                if appDelegate.bonjourServer.connectToServer(device) {
                    return
                }
            }
            navigationController?.popViewController(animated: true)
            if let vc = navigationController?.topViewController as? DevicesListViewController {
                vc.listTableView.reloadData()
                appDelegate.bonjourServer = BonjourServer()
            }
            
            navigationController?.navigationBar.isHidden = false
        }
    }
}
