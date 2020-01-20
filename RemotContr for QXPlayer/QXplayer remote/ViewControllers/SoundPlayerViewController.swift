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
        if sender.currentImage?.pngData() == UIImage(named: "play-button")?.pngData() {
            sender.setImage(UIImage(named: "pause"), for: .normal)
            if let data = "PAUSE".data(using: String.Encoding.utf8) {
                bonjourServer.send(data)
            }
        } else {
            sender.setImage(UIImage(named: "play-button"), for: .normal)
            if let data = "PLAY".data(using: String.Encoding.utf8) {
                bonjourServer.send(data)
            }
        }
    
        
        
    }
    
    @IBAction func backwardAction(_ sender: UIButton) {
    }
    @IBAction func forwardAction(_ sender: UIButton) {
    }
    @IBAction func repeatAction(_ sender: UIButton) {
    }
    @IBAction func goBackwardAction(_ sender: UIButton) {
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
            let trackInformation = try? JSONDecoder().decode(TrackInformation.self, from: data),
            let image = UIImage(data: trackInformation.imageData) else { return }
        
        trackNameLabel.text = trackInformation.trackName
        artistNameLabel.text = trackInformation.albumName
        trackImageView.image = image
        
        view.backgroundColor = UIColor(patternImage: image)
    }
    
    func didChangeServices() {
//        if let devices = bonjourServer.devices, let service = _service {
//
//            if devices.count == .zero {
//                navigationController?.popViewController(animated: true)
//                navigationController?.setNavigationBarHidden(false, animated: true)
//            } else {
//
//                for device in devices {
//                    if device == service {
//                        if bonjourServer.connectToServer(device) {
//                            return
//                        } else {
//                            bonjourServer.connectTo(device)
//                            return
//                        }
//                    }
//                }
//
//                navigationController?.popViewController(animated: true)
//                navigationController?.setNavigationBarHidden(false, animated: true)
//
//            }
//
//
//
//
//        }
    }
}
