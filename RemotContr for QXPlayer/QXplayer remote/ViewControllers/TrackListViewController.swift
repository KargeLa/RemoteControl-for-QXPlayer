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
    
    var trackImageData: [Data]?
    var trackListName: [String]? {
        didSet {
            tableView.reloadData()
        }
    }
    weak var delegate: SelectedDelegate?
    
    //MARK: - Outlets
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - LifeCyrcle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        navigationController?.navigationBar.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let viewControllers = tabBarController?.viewControllers else { return }
        
        for viewController in viewControllers {
            guard let vc = (viewController as? UINavigationController)?.topViewController as? SoundPlayerViewController else { return }
            trackListName = vc.trackList?.tracksInformation.map { $0.trackName }
            trackImageData = vc.trackList?.tracksInformation.map { $0.imageData }
            break
        }
        
        guard let trackImage = UIImage(data: (trackImageData?[0])!) else { return }
        
        backgroundImage.image = trackImage
    }
}
//MARK: - TableView DataSource & Delegate

extension TrackListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackListName?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        guard let trackImage = UIImage(data: (trackImageData?[indexPath.row])!) else { return cell}
        
        var cellImg: UIImageView = UIImageView(frame: CGRect(x: 0, y: 3, width: 40, height: 40))
        cellImg.image = trackImage
        cell.addSubview(cellImg)
        
        var cellLabel: UILabel = UILabel(frame: CGRect(x: 45, y: 0, width: 100, height: 40))
        cellLabel.text = trackListName?[indexPath.row] ?? " "
        cell.addSubview(cellLabel)
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentTrackName = trackListName?[indexPath.row] else { return }
        delegate?.didSelectRow(currentTrackName: currentTrackName)
    }
}
