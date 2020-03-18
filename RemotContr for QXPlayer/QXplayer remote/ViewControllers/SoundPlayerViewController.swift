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
    
    private let sendDataManager: SendData = SendDataManager()
    private lazy var receivingManager: ReceivingData = ReceivingDataManager(currentViewController: self)
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(dataCameFromTheServer(_: )), name: .dataCameFromTheServer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changedTheNumberOfDevices(_: )), name: .changedTheNumberOfDevices, object: nil)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    @objc private func dataCameFromTheServer(_ notification: Notification) {
        receivingManager.cameData(from: notification)
    }
    
    @objc private func changedTheNumberOfDevices(_ notification: Notification) {
        receivingManager.changeTheNumberOfDevice(navigationController: navigationController)
    }
    
    //MARK: - Action
    
    @IBAction func playOrPauseAction() {
        currentState = currentState.opposite
        sendDataManager.sendDataToComputerPlayer(command: currentState.rawValue)
    }
    
    @IBAction func backwardAction() {
         sendDataManager.sendDataToComputerPlayer(command: "back")
    }
    
    @IBAction func forwardAction() {
        sendDataManager.sendDataToComputerPlayer(command: "forward")
    }
    
    @IBAction func trackDurationAction(_ sender: UISlider) {
         sendDataManager.sendDataToComputerPlayer(currentTime: sender.value)
    }
    
    @IBAction func volumeAction(_ sender: UISlider) {
         sendDataManager.sendDataToComputerPlayer(volume: sender.value)
    }
}

//MARK: - SelectedDelegate

extension SoundPlayerViewController: SelectedDelegate {
    func changeFolder(path: String) {
        sendDataManager.sendDataToComputerPlayer(nameFolder: path)
    }
    
    func changedTrack(currentTrackName: String) {
        sendDataManager.sendDataToComputerPlayer(currentTrackName: currentTrackName)
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
    
    func dataAction(fileSystem: [File]) {
        trackListVC()?.fileSystem = fileSystem
    }
    
    
}
