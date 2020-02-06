//
//  ListTrackViewController.swift
//  QXplayer remote
//
//  Created by Ilya Lagutovsky on 1/30/20.
//  Copyright © 2020 MDSolution. All rights reserved.
//

import UIKit

protocol SelectedDelegate: class {
    func didSelectRow(currentTrackName: String)
}

class TrackListViewController: UIViewController {
    
    //MARK: - Properties
    
    var trackList: TrackList? {
        didSet {
            tableView.reloadData()
        }
    }
    weak var delegate: SelectedDelegate?
    
    //MARK: - Outlets
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var remoteControlStatusView: UIView!
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var constraintOfHeightRemoteControlStatusView: NSLayoutConstraint!
    @IBOutlet weak var constraintOfHeightVisualEffect: NSLayoutConstraint!
    
    //MARK: - Actions
    
    @IBAction func playButtonClicked(_ sender: Any) {
    }
    @IBAction func forwardButtonClicked(_ sender: Any) {
    }
    
    //MARK: - LifeCyrcle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        constraintOfHeightRemoteControlStatusView.constant = 0
//        constraintOfHeightVisualEffect.constant = 0
//        remoteControlStatusView.isHidden = true
        
        trackImageView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        trackImageView.layer.shadowOffset = CGSize(width: 0, height: 1)
        trackImageView.layer.shadowOpacity = 1.0
        trackImageView.layer.shadowRadius = 10.0
        trackImageView.layer.masksToBounds = false
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let viewControllers = tabBarController?.viewControllers else { return }
        
        for viewController in viewControllers {
            guard let vc = (viewController as? UINavigationController)?.topViewController as? SoundPlayerViewController else { return }
            trackList = vc.trackList
            backgroundImage.image = setBackgroundImage(from: trackList)
            break
        }
    }
    
    private func setBackgroundImage(from trackList: TrackList?) -> UIImage {
        guard let trackList = trackList,
            let image = UIImage(data: trackList.currentTrack.imageData) else { return UIImage() }
        
        return image
        
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
        guard let trackInformation = trackList?.tracksInformation[indexPath.row],
            let trackImage = UIImage(data: trackInformation.imageData) else { return }
        backgroundImage.image = trackImage
        
        delegate?.didSelectRow(currentTrackName: trackInformation.trackName)
    }
}
