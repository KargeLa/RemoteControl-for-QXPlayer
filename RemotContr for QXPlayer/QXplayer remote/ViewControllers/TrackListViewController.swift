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
            if oldValue?.tracksInformation.first?.trackName != trackList?.tracksInformation.first?.trackName {
                tableView?.reloadData()
            }
            guard trackImageView != nil else { return }
            trackImageView.setImage(with: trackList?.currentTrack.imageData)
            trackNameLabel.text = trackList?.currentTrack.trackName
            
            if backgroundImage != nil {
                backgroundImage.setImage(with: trackList?.currentTrack.imageData)
            }
        }
    }
    
    weak var delegate: SelectedDelegate?
    
    var currentState: StatePlay = .notPlayningMusic {
        didSet {
            switch currentState {
            case .playningMusic:
                playOrStopButton?.setImage(UIImage(named: "smallPause"), for: .normal)
            case .notPlayningMusic:
                playOrStopButton?.setImage(UIImage(named: "smallPlay"), for: .normal)
            }
        }
    }
    
    lazy var soundPlayerVC = { [weak self] () -> SoundPlayerViewController? in
        
        if let viewControllers = self?.tabBarController?.viewControllers {
            for viewController in viewControllers {
                if let vc = (viewController as? UINavigationController)?.topViewController as? SoundPlayerViewController {
                    return vc
                }
            }
        } else if let viewController = self?.parent as? SoundPlayerViewController { // for ipad
            return viewController
        }
    
        return nil
    }
    
    lazy private var tapGestureRecognaizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.addTarget(self, action: #selector(showSoundPlayer))
        return recognizer
    }()
    
    private var transitionAnimator = UIViewPropertyAnimator()
    
    //MARK: - Outlets
    
    @IBOutlet weak var playOrStopButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightPlayMusicConstraint: NSLayoutConstraint!
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var playView: UIView!
    
    //MARK: - LifeCyrcle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = true
        trackImageView?.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        trackImageView?.layer.shadowOffset = CGSize(width: 0, height: 1)
        trackImageView?.layer.shadowOpacity = 1.0
        trackImageView?.layer.shadowRadius = 10.0
        trackImageView?.layer.masksToBounds = false
        
        playView?.addGestureRecognizer(tapGestureRecognaizer)
        playView?.layer.cornerRadius = 10
        playView?.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let soundPlayerVC = soundPlayerVC() else { return }
        
        switch soundPlayerVC.currentState {
        case .playningMusic:
            heightPlayMusicConstraint?.constant = 70
            currentState = .playningMusic
        case .notPlayningMusic:
            heightPlayMusicConstraint?.constant = 0
            currentState = .notPlayningMusic
        }
        trackList?.currentTrack = soundPlayerVC.trackList!.currentTrack
    }
    
    //MARK: - IBAction
    
    @IBAction func playButton(_ sender: UIButton) {
        currentState = currentState.opposite
        guard let soundPlayerVC = soundPlayerVC() else { return }
        soundPlayerVC.playOrPauseAction()
    }
    
    @IBAction func nextButton(_ sender: Any) {
        guard let currentTrack = trackList?.nextTrack() else { return }
        delegate?.changedTrack(currentTrackName: currentTrack.trackName)
    }
    
    //MARK: - Supporting
    
    private func showPlayView() {
        if heightPlayMusicConstraint?.constant == 0 {
            transitionAnimator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.5, animations: { [weak self] in
                self?.heightPlayMusicConstraint.constant = 70
                self?.view.layoutIfNeeded()
            })
            if currentState == .notPlayningMusic {
                currentState = currentState.opposite
                guard let soundPlayerVC = soundPlayerVC() else { return }
                soundPlayerVC.playOrPauseAction()
            } else {
                return
            }
            transitionAnimator.startAnimation()
        }
    }
    
    @objc private func showSoundPlayer() {
        tabBarController?.selectedIndex = 0
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
