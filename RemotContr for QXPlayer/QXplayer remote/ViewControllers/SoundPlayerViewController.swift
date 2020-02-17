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
    
    @IBOutlet weak var nameFolderLabel: UILabel!
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var trackSlider: UISlider!
    @IBOutlet weak var soundSlider: UISlider!
    @IBOutlet weak var playOrPauseButton: UIButton!
    
    //MARK: - Properties
    
    lazy private var appDelegate = AppDelegate.shared()
    
    var trackList: TrackList? {
        didSet {
            guard let currentTrack = trackList?.currentTrack else { return }
            updateUI(trackInformation: currentTrack)
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
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(dataCameFromTheServer(_: )), name: .dataCameFromTheServer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changedTheNumberOfDevices(_: )), name: .changedTheNumberOfDevices, object: nil)
        navigationController?.navigationBar.isHidden = true
    }
  
    //MARK: - Action
    
    @IBAction func playOrPauseAction() {
        currentState = currentState.opposite
        sendCommand(command: currentState.rawValue)
    }
    
    @IBAction func backwardAction(_ sender: UIButton) {
        guard let _ = trackList?.prevTrack() else { return }
        sendCommand(command: "back")
    }
    
    @IBAction func forwardAction(_ sender: UIButton) {
        guard let _ = trackList?.nextTrack() else { return }
        sendCommand(command: "forward")
    }
    
    //MARK: - Supporting
    
    private func updateUI(trackInformation: TrackInformation ) {
        guard let trackImage = UIImage(data: trackInformation.imageData) else { return }
        trackNameLabel.text = trackInformation.trackName
        artistNameLabel.text = trackInformation.albumName
        trackImageView.image = trackImage
        view.backgroundColor = UIColor(patternImage: trackImage)
    }
    
    private func sendCommand(command: String) {
        if let data = command.data(using: .utf8) {
            appDelegate.bonjourServer.send(data)
        }
    }
    
    @objc private func dataCameFromTheServer(_ notification: Notification) {
        if let data = notification.userInfo?["data"] as? Data {
            guard let trackList = try? JSONDecoder().decode(TrackList.self, from: data) else { return }
            self.trackList = trackList
            trackListVC()?.trackList = trackList
            trackListVC()?.delegate = self
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

//MARK: - SelectedDelegate

extension SoundPlayerViewController: SelectedDelegate {
    func changedTrack(currentTrackName: String) {
        
        if let trackInformation = trackList?.searchTrack(byTrackName: currentTrackName) {
            trackList?.currentTrack = trackInformation
            sendCommand(command: currentTrackName)
        }
    }
    
    
}
