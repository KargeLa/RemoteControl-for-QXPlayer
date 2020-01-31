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
    
    //MARK: - Properties
    
    var _service: NetService?
    private var bonjourServer: BonjourServer! {
        didSet {
            bonjourServer.delegate = self
        }
    }
    
    var trackList: TrackList?
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let image = trackImageView.image {
            view.backgroundColor = UIColor(patternImage: image)
        }
        
        bonjourServer = BonjourServer()
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        if let service = _service {
            bonjourServer.connectTo(service)
        }
    }
  
    //MARK: - Action
    
    @IBAction func playOrPauseAction(_ sender: UIButton) {
        
        if sender.currentImage?.pngData() == UIImage(named: "pause")?.pngData() {
            sender.setImage(UIImage(named: "play-button"), for: .normal)
            
            if let data = "pause".data(using: .utf8) {
                bonjourServer.send(data)
            }
        } else {
            sender.setImage(UIImage(named: "pause"), for: .normal)
            if let data = "play".data(using: .utf8) {
                bonjourServer.send(data)
            }
        }
    
    }
    
    @IBAction func backwardAction(_ sender: UIButton) {
        guard let prevTrack = trackList?.prevTrack() else { return }
        updateUI(trackInformation: prevTrack)
        if let data = "back".data(using: .utf8) {
            bonjourServer.send(data)
        }
        
    }
    
    @IBAction func forwardAction(_ sender: UIButton) {
        guard let nextTrack = trackList?.nextTrack() else { return }
        updateUI(trackInformation: nextTrack)
        if let data = "forward".data(using: .utf8) {
            bonjourServer.send(data)
        }
    }
    
    @IBAction func repeatAction(_ sender: UIButton) {
        print(#function)
    }
    
    @IBAction func goBackwardAction(_ sender: UIButton) {
        print(#function)
    }
    
    private func updateUI(trackInformation: TrackInformation ) {
        trackNameLabel.text = trackInformation.trackName
        artistNameLabel.text = trackInformation.albumName
        
        guard let trackImage = UIImage(data: trackInformation.imageData) else { return }
        
        trackImageView.image = trackImage
        view.backgroundColor = UIColor(patternImage: trackImage)
    }
    
    private func subscribeToDelegate() {
        if let viewControllers = tabBarController?.viewControllers {
            for viewController in viewControllers {
                if let vc = (viewController as? UINavigationController)?.topViewController as? TrackListViewController {
                    vc.delegate = self
                    break
                }
                
            }
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
        
        self.trackList = TrackList(tracksInformation: trackList.tracksInformation, currentTrack: trackList.currentTrack ?? trackList.tracksInformation[0])
        updateUI(trackInformation: (self.trackList?.currentTrack)! )
        subscribeToDelegate()
        
    }
    
    func didChangeServices() {
        if let devices = bonjourServer.devices, let service = _service {

            if devices.count == .zero {
                navigationController?.popViewController(animated: true)
                navigationController?.setNavigationBarHidden(false, animated: true)
            } else {
                for device in devices {
                    if device == service {
                        if bonjourServer.connectToServer(device) {
                            return
                        } else {
                            bonjourServer.connectTo(device)
                            return
                        }
                    }
                }
                
                navigationController?.popViewController(animated: true)
                navigationController?.setNavigationBarHidden(false, animated: true)
            }

        }
    }
}

extension SoundPlayerViewController: SelectedDelegate {
    func didSelectRow(currentTrackName: String) {
        
        if let data = currentTrackName.data(using: .utf8) {
            bonjourServer.send(data)
        }
        
        for trackInfo in trackList!.tracksInformation {
            if trackInfo.trackName == currentTrackName {
                updateUI(trackInformation: trackInfo)
                trackList?.currentTrack = trackInfo
            }
        }

    }
    
    
}
