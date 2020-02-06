//
//  ListTrackViewController.swift
//  QXplayer remote
//
//  Created by Ilya Lagutovsky on 1/30/20.
//  Copyright © 2020 MDSolution. All rights reserved.
//

import UIKit

protocol SelectedDelegate: class {
    func changedTrack(currentTrackName: String)
}

class TrackListViewController: UIViewController {
    
    //MARK: - Properties
    
    var trackList: TrackList? {
        didSet {
            guard trackImageView != nil else { return }
            guard let data = trackList?.currentTrack.imageData, let image = UIImage(data: data) else { return }
            trackImageView.image = image
            trackNameLabel.text = trackList?.currentTrack.trackName
            
            if backgroundImage != nil {
                backgroundImage.image = image
            }
        }
    }
    
    weak var delegate: SelectedDelegate?
    
    var currentState: StatePlay = .notPlayningMusic {
        didSet {
            switch currentState {
            case .playningMusic:
                playOrStopButton.setImage(UIImage(named: "smallPause"), for: .normal)
            case .notPlayningMusic:
                playOrStopButton.setImage(UIImage(named: "smallPlay"), for: .normal)
            }
        }
    }
    
    lazy var soundPlayerVC = { [weak self] () -> SoundPlayerViewController? in
        guard let viewControllers = self?.tabBarController?.viewControllers else { return nil }
        
        for viewController in viewControllers {
            if let vc = (viewController as? UINavigationController)?.topViewController as? SoundPlayerViewController {
                return vc
            }
        }
        return nil
    }
    
    //MARK: - Outlets
    
    @IBOutlet weak var playOrStopButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightPlayMusicConstraint: NSLayoutConstraint!
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    
    //MARK: - LifeCyrcle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        trackImageView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        trackImageView.layer.shadowOffset = CGSize(width: 0, height: 1)
        trackImageView.layer.shadowOpacity = 1.0
        trackImageView.layer.shadowRadius = 10.0
        trackImageView.layer.masksToBounds = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let soundPlayerVC = soundPlayerVC() else { return }
        
        switch soundPlayerVC.currentState {
        case .playningMusic:
            heightPlayMusicConstraint.constant = 70
            currentState = .playningMusic
        case .notPlayningMusic:
            heightPlayMusicConstraint.constant = 0
            currentState = .notPlayningMusic
        }
        
        trackList = soundPlayerVC.trackList
        tableView.reloadData() // need change
    }
    
    //MARK: - IBAction
    
    @IBAction func playButton(_ sender: UIButton) {
        currentState = currentState.opposite
        guard let soundPlayerVC = soundPlayerVC() else { return }
        soundPlayerVC.playOrPauseAction()
    }
    
    @IBAction func nextButton(_ sender: Any) {
        guard let nextTrack = trackList?.nextTrack() else { return }
        delegate?.changedTrack(currentTrackName: nextTrack.trackName)
    }
    
    //MARK: - Supporting
    
    private func showPlayView() {
        if heightPlayMusicConstraint.constant == 0 {
            heightPlayMusicConstraint.constant = 70
        }
    }
}
//MARK: - TableView DataSource & Delegate

extension TrackListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackList?.tracksInformation.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TrackTableViewCell else { return UITableViewCell() }
    
        cell.setCell(from: trackList?.tracksInformation[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let trackInformation = trackList?.tracksInformation[indexPath.row] else { return }
       
        trackList?.currentTrack = trackInformation
        
        showPlayView()
        delegate?.changedTrack(currentTrackName: trackInformation.trackName)
    }
}
