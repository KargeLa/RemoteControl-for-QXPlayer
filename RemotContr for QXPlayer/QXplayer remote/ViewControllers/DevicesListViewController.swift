//
//  ListViewController.swift
//  QXplayer remote
//
//  Created by Алексей Смоляк on 1/15/20.
//  Copyright © 2020 MDSolution. All rights reserved.
//

import UIKit

class DevicesListViewController: UIViewController {
    //MARK: - Outlets
    
    @IBOutlet weak var listTableView: UITableView! {
        didSet {
            listTableView.delegate = self
            listTableView.dataSource = self
        }
    }
    
    lazy private var appDelegate = AppDelegate.shared()
    
    //MARK: - LifeCycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(changedTheNumberOfDevices(_: )), name: .changedTheNumberOfDevices, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .changedTheNumberOfDevices, object: nil)
    }
    
    @objc func changedTheNumberOfDevices(_ notification: Notification) {
        listTableView.reloadData()
    }
    
    
}

    //MARK: - UITableViewDelegate, UITableViewDataSource

extension DevicesListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.bonjourServer.devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.listTableView.dequeueReusableCell(withIdentifier: "listOfTheDevices", for: indexPath)
        let device = appDelegate.bonjourServer.devices[indexPath.row]
        cell.textLabel?.text = device.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !appDelegate.bonjourServer.devices.isEmpty {
            appDelegate.bonjourServer.connectTo(appDelegate.bonjourServer.devices[indexPath.row])
        }
    }
    
}
