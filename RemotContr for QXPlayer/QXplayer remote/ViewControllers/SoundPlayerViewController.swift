//
//  SoundPlayerViewController.swift
//  QXplayer remote
//
//  Created by Ilya Lagutovsky on 1/16/20.
//  Copyright © 2020 MDSolution. All rights reserved.
//

import UIKit

class SoundPlayerViewController: UIViewController {
    
    //MARK: - Properties
    
    var playCommand: Bool = false
    var timer = Timer()
    let formatter = DateComponentsFormatter()
    var currentTime = 0
    
    var currentTrack: MetaData? {
        didSet {
            guard let currentTrack = currentTrack else { return }
            updateUI(trackInformation: currentTrack)
        }
    }
    
    private lazy var appDelegate = AppDelegate.shared()
    
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
    
    lazy var trackListVC = { [weak self] () -> TrackListViewController? in
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
    
    //MARK: - Outlets
    
    @IBOutlet weak var nameFolderLabel: UILabel!
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var playOrPauseButton: UIButton!
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var currentVolumeSlider: UISlider!
    @IBOutlet weak var maxCurrentTimeLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    //MARK: - Actions
    
    @IBAction func currentTimeChenged(_ sender: UISlider) {
        timeConvert(maxCurrentTime: Int(currentTimeSlider.value))
        currentTime = Int(currentTimeSlider.value)
    }
    
    @IBAction func currentVolumeChanged(_ sender: UISlider) {
    }
    
    @IBAction func playOrPauseAction() {
        playCommand.toggle()
        if playCommand == true {
            currentState = currentState.opposite
            let json = ["action": 1]
            sendData(json: json)
        } else if playCommand == false {
            currentState = currentState.opposite
            let json = ["action": 2, "currentTime": 20]
            sendData(json: json)
        }
    }
    
    @IBAction func previousButtonClicked(_ sender: UIButton) {
        let json = ["action": 4]
        sendData(json: json)
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        let json = ["action": 3]
        sendData(json: json)
    }
    
    //MARK: - LifeCyrcle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackListVC()?.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(dataCameFromTheServer(_: )), name: .dataCameFromTheServer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changedTheNumberOfDevices(_: )), name: .changedTheNumberOfDevices, object: nil)
        navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - Supporting
    
    @objc private func dataCameFromTheServer(_ notification: Notification) {
        if let data = notification.userInfo?["data"] as? Data {
            if let package = try? JSONDecoder().decode(PlayerManager.self, from: data),
                let actionInt = package.action,
                
                let action = ActionType(rawValue: actionInt) {
                switch action {
                case .connect:
                    let trackList = package.nameOfTracks
                    trackListVC()?.trackList = trackList
                    
                    guard let currentTrackInformation = package.currentTrack else {
                        return
                    }
                    self.currentTrack = currentTrackInformation
                    trackListVC()?.currentTrack = currentTrackInformation
                    updateUI(trackInformation: currentTrackInformation)
                case .play:
                    //                    currentState = currentState.opposite
                    sendCommand(command: currentState.rawValue)
                    break
                case .pause:
                    currentState = currentState.opposite
                    sendCommand(command: currentState.rawValue)
                    break
                case .next:
                    break
                case .prev:
                    break
                case .volume:
                    break
                case .time:
                    break
                case .changedTrack:
                    guard let currentTrackInformation = package.currentTrack else {
                        return
                    }
                    self.currentTrack = currentTrackInformation
                    trackListVC()?.currentTrack = currentTrack
                    break
                }
            }
        }
    }
    
    private func sendDataToQXPlayer(metaData: MetaData? = nil, action: Int? = nil, maxCurrentTime: Int? = nil, currentTime: Int? = nil, currentVolume: Float? = nil, currentTrackName: String? = nil) {
        
        let playerData = PlayerManager(currentTrack: metaData, action: action, maxCurrentTime: maxCurrentTime, currentTime: currentTime, currentVolume: currentVolume, currentTrackName: currentTrackName)
        
        guard let data = playerData.json else { return }
        appDelegate.bonjourServer.send(data)
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
    
    private func timeConvert (maxCurrentTime: Int) -> String {
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        let strMaxCurrentTime = formatter.string(from: TimeInterval(maxCurrentTime))
        return strMaxCurrentTime!
    }
    
    private func updateUI(trackInformation: MetaData ) {
        guard let trackImage = UIImage(data: trackInformation.albumArt) else { return }
        trackNameLabel.text = trackInformation.title
        artistNameLabel.text = trackInformation.albumName
        trackImageView.image = trackImage
        view.backgroundColor = UIColor(patternImage: trackImage)
    }
    
    private func sendCommand(command: String) {
        if let data = command.data(using: .utf8) {
            appDelegate.bonjourServer.send(data)
        }
    }
    
    func sendData(json: [String: Any]) {
        guard let commandData = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted]) else {
            return
        }
        appDelegate.bonjourServer.send(commandData)
    }
}


//MARK: - SelectedDelegate

extension SoundPlayerViewController: SelectedDelegate {
    func changedTrack(currentTrackName: String, action: Int) {
        sendDataToQXPlayer(action: action, currentTrackName: currentTrackName)
    }
}
