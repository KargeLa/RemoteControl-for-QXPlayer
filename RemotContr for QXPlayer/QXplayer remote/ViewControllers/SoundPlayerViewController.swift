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
    @IBOutlet weak var trackSlider: UISlider!
    @IBOutlet weak var soundSlider: UISlider!
    @IBOutlet weak var playOrPauseButton: UIButton!
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var currentVolumeSlider: UISlider!
    @IBOutlet weak var maxCurrentTimeLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    //MARK: - Actions
    
    @IBAction func currentTimeChenged(_ sender: UISlider) {
    }
    
    @IBAction func currentVolumeChanged(_ sender: UISlider) {
    }
    
    @IBAction func playOrPauseAction() {
        currentState = currentState.opposite
        sendCommand(command: currentState.rawValue)
    }
    
    @IBAction func backwardAction(_ sender: UIButton) {
        guard let _ = trackList?.prevTrack() else { return }
        sendCommand(command: "back")
    }
    
    func forward() {
        guard let _ = trackList?.nextTrack() else { return }
        sendCommand(command: "forward")
    }
    
    @IBAction func forwardAction(_ sender: UIButton) {
        guard let _ = trackList?.nextTrack() else { return }
        sendCommand(command: "forward")
    }
    
    //MARK: - LifeCyrcle
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "container" { // for only ipda
            let trackListVc = segue.destination as! TrackListViewController
            trackListVc.delegate = self
        }
    }
    
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
        guard let data = body else {
            return
        }
        if let trackList = try? JSONDecoder().decode(TrackList.self, from: data) {
            self.trackList = trackList
            trackListVC()?.trackList = trackList
            trackListVC()?.delegate = self
        }
        //        let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        if let package = try? JSONDecoder().decode(Package.self, from: data),
            let actionInt = package.action,
            let action = ActionType(rawValue: actionInt) {
            switch action {
            case .play:
                currentState = currentState.opposite
                sendCommand(command: currentState.rawValue)
                currentTimeSlider.value = Float(package.currentTime!)
                currentTimeLabel.text = "\(package.currentTime!)"
                break
            case .pause:
                currentState = currentState.opposite
                sendCommand(command: currentState.rawValue)
                currentTimeSlider.value = Float(package.currentTime!)
                currentTimeLabel.text = "\(package.currentTime!)"
                break
            case .next:
                guard let _ = trackList?.nextTrack() else { return }
                sendCommand(command: "forward")
                currentTimeSlider.value = Float(package.currentTime!)
                currentTimeLabel.text = "\(package.currentTime!)"
                break
            case .prev:
                guard let _ = trackList?.prevTrack() else { return }
                sendCommand(command: "back")
                currentTimeSlider.value = Float(package.currentTime!)
                currentTimeLabel.text = "\(package.currentTime!)"
                break
            case .volume:
                break
            case .time:
                break
            }
        }
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
                navigationController?.popViewController(animated: true)
                navigationController?.navigationBar.isHidden = false
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
