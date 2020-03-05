//
//  SoundPlayerViewController.swift
//  QXplayer remote
//
//  Created by Ilya Lagutovsky on 1/16/20.
//  Copyright © 2020 MDSolution. All rights reserved.
//

import UIKit

class SoundPlayerViewController: UIViewController {

    //MARK: - Outlets
    
    @IBOutlet private weak var nameFolderLabel: UILabel!
    @IBOutlet private weak var trackImageView: UIImageView!
    @IBOutlet private weak var trackNameLabel: UILabel!
    @IBOutlet private weak var artistNameLabel: UILabel!
    @IBOutlet private weak var trackSlider: UISlider!
    @IBOutlet private weak var soundSlider: UISlider!
    @IBOutlet private weak var playOrPauseButton: UIButton!
    
    //MARK: - Properties
    
    private lazy var appDelegate = AppDelegate.shared()
    private let playerManager = PlayerManager()
    
    var currentTrack: MetaData? {
        didSet {
            trackNameLabel.text = currentTrack?.title
            artistNameLabel.text = currentTrack?.albumName
            trackImageView.setImage(with: currentTrack?.albumArt)
            view.backgroundColor = UIColor(patternImage: trackImageView.image!)
            trackListVC()?.currentTrack = currentTrack
        }
    }
        
    var currentState: StatePlay = .notPlayningMusic {
        didSet {
            switch currentState {
            case .playningMusic:
                playOrPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            case .notPlayningMusic:
                playOrPauseButton.setImage(UIImage(named: "play-button"), for: .normal)
            }
        }
    }
    
    private lazy var trackListVC = { [weak self] () -> TrackListViewController? in
        if let viewControllers = self?.tabBarController?.viewControllers {
            for viewController in viewControllers {
                if let vc = (viewController as? UINavigationController)?.topViewController as? TrackListViewController {
                    return vc
                }
            }
        } else if let viewControllers = self?.children { // for ipad
            for viewController in viewControllers {
                if let vc = viewController as? TrackListViewController {
                    return vc
                }
            }
        }
        return nil
    }
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackListVC()?.delegate = self
        playerManager.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(dataCameFromTheServer(_: )), name: .dataCameFromTheServer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changedTheNumberOfDevices(_: )), name: .changedTheNumberOfDevices, object: nil)
        navigationController?.navigationBar.isHidden = true
    }
  
    //MARK: - Action
    
    @IBAction func playOrPauseAction() {
        currentState = currentState.opposite
        sendDataToComputerPlayer(command: currentState.rawValue)
    }
    
    @IBAction func backwardAction() {
        sendDataToComputerPlayer(command: "back")
    }
    
    @IBAction func forwardAction() {
        sendDataToComputerPlayer(command: "forward")
    }
    
    @IBAction func trackDurationAction(_ sender: UISlider) {
        sendDataToComputerPlayer(currentTime: sender.value)
    }
    
    @IBAction func volumeAction(_ sender: UISlider) {
        sendDataToComputerPlayer(volume: sender.value)
    }
    
    
    //MARK: - Supporting
    
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
    
    private func sendDataToComputerPlayer(volume: Float? = nil, metaData: MetaData? = nil, command: String? = nil, currentTime: Float? = nil, listTrack: [String]? = nil, currentTrackName: String? = nil) {
        
        let playerData = PlayerData(volume: volume, metaData: metaData, command: command, currentTime: currentTime, listTrack: listTrack, currentTrackName: currentTrackName)
        
        guard let data = playerData.json else { return }
        appDelegate.bonjourServer.send(data)
    }
    
}

//MARK: - SelectedDelegate

extension SoundPlayerViewController: SelectedDelegate {
    func changedTrack(currentTrackName: String) {
        sendDataToComputerPlayer(currentTrackName: currentTrackName)
    }
}

//MARK: - PlayerDataActionsDelegate

extension SoundPlayerViewController: PlayerDataActionsDelegate {
    func dataAction(volume: Float) {
        soundSlider.value = volume
    }
    
    func dataAction(metaData: MetaData) {
        currentTrack = metaData
    }
    
    func dataAction(command: String) {
        switch command {
        case StatePlay.notPlayningMusic.rawValue: currentState = .notPlayningMusic
        case StatePlay.playningMusic.rawValue: currentState = .playningMusic
        default:
            print(#function)
        }
    }
    
    func dataAction(currentTime: Float) {
        trackSlider.value = currentTime
    }
    
    func dataAction(listTrack: [String]) {
        trackListVC()?.listTracks = listTrack
    }
    
    
}
