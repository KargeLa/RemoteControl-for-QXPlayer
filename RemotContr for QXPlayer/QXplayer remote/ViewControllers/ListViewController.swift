//
//  ListViewController.swift
//  QXplayer remote
//
//  Created by Алексей Смоляк on 1/15/20.
//  Copyright © 2020 MDSolution. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    
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
    
    //MARK: - Actions
    
    //MARK: - LifeCyrcle
    override func viewDidLoad() {
        super.viewDidLoad()
        bonjourServerForDevicesList = BonjourServer()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let destinationVC = segue.destination as? SoundPlayerViewController,
            let service = service else { return }
        destinationVC.service = service
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bonjourServerForDevicesList.devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.listTableView.dequeueReusableCell(withIdentifier: "listOfTheDevices", for: indexPath)
        let device = bonjourServerForDevicesList.devices[indexPath.row]
        cell.textLabel?.text = device.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if !bonjourServerForDevicesList.devices.isEmpty {
//            let service = bonjourServerForDevicesList.devices[indexPath.row]
//            bonjourServerForDevicesList.connectTo(service)
//        }
//        let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "RemoteTabBarController") as! UITabBarController
//        tabBarController.modalPresentationStyle = .fullScreen
//        self.present(tabBarController, animated: false) {
//               //This selected index will be the index of your view controller you want to present
//               tabBarController.selectedIndex = 0
//            
//           }
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if !bonjourServerForDevicesList.devices.isEmpty {
            service = bonjourServerForDevicesList.devices[indexPath.row]
        }
        
        return indexPath
    }
}

//MARK: - BonjourServerDelegate
extension ListViewController: BonjourServerDelegate {
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
