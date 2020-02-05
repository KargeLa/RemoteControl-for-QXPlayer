//
//  ListViewController.swift
//  QXplayer remote
//
//  Created by Алексей Смоляк on 1/15/20.
//  Copyright © 2020 MDSolution. All rights reserved.
//

import UIKit

class DevicesListViewController: UIViewController {
    
    //MARK: - Properties
    
    private var bonjourServerForDevicesList: BonjourServer! {
        didSet {
            bonjourServerForDevicesList.delegate = self
        }
    }
    private var service: NetService?
    
    //MARK: - Outlets
    
    @IBOutlet weak var listTableView: UITableView! {
        didSet {
            listTableView.delegate = self
            listTableView.dataSource = self
        }
    }
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bonjourServerForDevicesList = BonjourServer()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let destinationVC = segue.destination as? SoundPlayerViewController,
            let service = service else { return }
        destinationVC._service = service
    }
    
    private func transferToAnotherControlelr(withKey key: NetService?) {
        if let response = UserDefaults.standard.string(forKey: "repeatDevice") {
            if response == key?.name {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Player") as? SoundPlayerViewController else { return }
                vc._service = key
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

    //MARK: - UITableViewDelegate, UITableViewDataSource

extension DevicesListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bonjourServerForDevicesList.devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.listTableView.dequeueReusableCell(withIdentifier: "listOfTheDevices", for: indexPath)
        let device = bonjourServerForDevicesList.devices[indexPath.row]
        cell.textLabel?.text = device.name
        
        transferToAnotherControlelr(withKey: device)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if !bonjourServerForDevicesList.devices.isEmpty {
            service = bonjourServerForDevicesList.devices[indexPath.row]
            UserDefaults.standard.set(service?.name, forKey: "repeatDevice")
        }
        
        return indexPath
    }
}

    //MARK: - BonjourServerDelegate

extension DevicesListViewController: BonjourServerDelegate {
    func connected() {
        print("connected")
    }
    
    func disconnected() {
        print("disconnected")
    }
    
    func handleBody(_ body: Data?) {
        print("no body")
    }
    
    func didChangeServices() {
        listTableView.reloadData()
    }
}
