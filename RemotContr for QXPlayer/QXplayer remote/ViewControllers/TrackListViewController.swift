//
//  ListTrackViewController.swift
//  QXplayer remote
//
//  Created by Ilya Lagutovsky on 1/30/20.
//  Copyright © 2020 MDSolution. All rights reserved.
//

import UIKit

protocol SelectedDelegate: class {
    func changedTrack(currentTrackName: String, action: Int)
    func changeFolder(path: String, action: Int)
}

class TrackListViewController: UIViewController {
    
    //MARK: - Properties
    
    var fileSystem: [File]? {
        didSet {
            tableView?.reloadData()
        }
    }
    
    var remoteControle = SoundPlayerViewController()
    var currentTrack: MetaData? {
        didSet {
            backgroundImage?.setImage(with: currentTrack?.albumArt)
            if let text = currentTrack?.title {
                trackNameLabel?.text = text
            }
            if let trackImage = UIImage(data: currentTrack!.albumArt) {
                trackImageView?.image = trackImage
            }
        }
    }
    var trackList: [String]?
    
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
        currentTrack = soundPlayerVC.currentTrack
    }
    
    //MARK: - Actions
    
    @IBAction func playButton(_ sender: UIButton) {
        currentState = currentState.opposite
        guard let soundPlayerVC = soundPlayerVC() else { return }
        soundPlayerVC.playOrPauseAction()
    }
    
    @IBAction func nextButton(_ sender: Any) {
        let json = ["action": 3]
        soundPlayerVC()?.nextButtonClicked(sender as! UIButton)
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
    
    private func returnPreviousPath() -> String {
        var returnPath = ""
        guard let fileSystem = fileSystem else { return returnPath }

        if let folder = fileSystem.first(where: { $0.type == .folder }) {
            returnPath = folder.path
            let countFolderName = folder.name.count
            
            for _ in 0..<countFolderName {
                returnPath.removeLast()
            }
            returnPath.removeLast()
            return returnPath
        } else if let track = fileSystem.first(where: { $0.type == .music }) {
            returnPath = track.path
            var deleteSymbol: Character = " "
            
            while deleteSymbol != "/" {
                deleteSymbol = returnPath.removeLast()
            }
            deleteSymbol = returnPath.removeLast()
            while deleteSymbol != "/" {
                deleteSymbol = returnPath.removeLast()
            }
            return returnPath
        }
        
        return returnPath
    }
}
//MARK: - TableView DataSource & Delegate

extension TrackListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (fileSystem?.count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let previousFolderCell = tableView.dequeueReusableCell(withIdentifier: "previousFolder", for: indexPath) as! TrackTableViewCell
            previousFolderCell.setPreviousFolder()
            return previousFolderCell
        }
        
        if fileSystem![indexPath.row - 1].type == .folder {
            let folderCell = tableView.dequeueReusableCell(withIdentifier: "folderCell", for: indexPath) as! TrackTableViewCell
            folderCell.setfolder(name: fileSystem![indexPath.row - 1].name)
            return folderCell
        } else if fileSystem![indexPath.row - 1].type == .music {
            let songDataBoxCell = tableView.dequeueReusableCell(withIdentifier: "songDataBox", for: indexPath) as! TrackTableViewCell
            songDataBoxCell.setCell(from: fileSystem![indexPath.row - 1].name)
            return songDataBoxCell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            delegate?.changeFolder(path: returnPreviousPath(), action: 8)
            return
        }
        
        if fileSystem![indexPath.row - 1].type == .folder {
            delegate?.changeFolder(path: fileSystem![indexPath.row - 1].path, action: 8)
            return
        } else if fileSystem![indexPath.row - 1].type == .music {
            showPlayView()
            delegate?.changedTrack(currentTrackName: fileSystem![indexPath.row - 1].name, action: 7)
            return
        }
    }
}
