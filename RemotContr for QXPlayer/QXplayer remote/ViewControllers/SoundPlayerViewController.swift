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
    
    var _service: NetService?
    var trackList: TrackList? {
        didSet {
            guard let currentTrack = trackList?.currentTrack else { return }
            updateUI(trackInformation: currentTrack)
        }
    }
    
    private var bonjourServer: BonjourServer! {
        didSet {
            bonjourServer.delegate = self
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
        guard let viewControllers = self?.tabBarController?.viewControllers else { return nil }
        
        for viewController in viewControllers {
            if let vc = (viewController as? UINavigationController)?.topViewController as? TrackListViewController {
                return vc
            }
        }
        return nil
    }
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let image = trackImageView.image {
            view.backgroundColor = UIColor(patternImage: image)
        }
        
        bonjourServer = BonjourServer()
        navigationController?.navigationBar.isHidden = true
        
        if let service = _service {
            bonjourServer.connectTo(service)
        }
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
            bonjourServer.send(data)
        }
    }
    
    
}

    //MARK: - BonjourServerDelegate

extension SoundPlayerViewController: BonjourServerDelegate {
    func connected() {
        print("connected")
    }
    
    func disconnected() {
        print("disconnected")
    }
    
    func handleBody(_ body: Data?) {
        guard let data = body,
            let trackList = try? JSONDecoder().decode(TrackList.self, from: data) else { return }
        
        
        self.trackList = trackList
        trackListVC()?.delegate = self
    }
    
    func didChangeServices() {
        if let devices = bonjourServer.devices, let service = _service {
            if devices.count == .zero {
                navigationController?.popViewController(animated: true)
                navigationController?.navigationBar.isHidden = false
            } else {
                if let device = devices.first(where: { $0 == service }) {
                    if bonjourServer.connectToServer(device) {
                        return
                    } else {
                         bonjourServer.connectTo(device)
                    }
                }
            }
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
