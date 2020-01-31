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

    @IBOutlet weak var tableView: UITableView!
    var trackListName: [String]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    weak var delegate: SelectedDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let viewControllers = tabBarController?.viewControllers else { return }
        
        for viewController in viewControllers {
            guard let vc = (viewController as? UINavigationController)?.topViewController as? SoundPlayerViewController else { return }
            trackListName = vc.trackList?.tracksInformation.map { $0.trackName }
            break
        }
        
    }

}

extension TrackListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackListName?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = trackListName?[indexPath.row] ?? " "
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentTrackName = trackListName?[indexPath.row] else { return }
        delegate?.didSelectRow(currentTrackName: currentTrackName)
    }
    
}
