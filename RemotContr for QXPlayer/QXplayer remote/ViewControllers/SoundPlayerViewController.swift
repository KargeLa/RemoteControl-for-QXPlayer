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
    
    var service: NetService?
    private var bonjourServer: BonjourServer! {
        didSet {
            bonjourServer.delegate = self
        }
    }
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bonjourServer = BonjourServer()
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        if let service = service {
            bonjourServer.connectTo(service)
        }
    }
  
    //MARK: - Action
    
    @IBAction func playOrPauseAction(_ sender: UIButton) {
        if sender.titleLabel?.text == "PLAY" {
            sender.setTitle("STOP", for: .normal)
            if let data = sender.titleLabel?.text?.data(using: String.Encoding.utf8) {
                bonjourServer.send(data)
            }
        } else {
            trackNameLabel.text = " "
            sender.setTitle("PLAY", for: .normal)
            if let data = sender.titleLabel?.text?.data(using: String.Encoding.utf8) {
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
            let trackInformation = try? JSONDecoder().decode(TrackInformation.self, from: data) else { return }
        
        trackImageView.image = UIImage(data: trackInformation.imageData)
        trackNameLabel.text = trackInformation.nameTrack
        artistNameLabel.text = trackInformation.nameAlbum
    }
    
    func didChangeServices() {
        print("didChangeServices")
    }
}
