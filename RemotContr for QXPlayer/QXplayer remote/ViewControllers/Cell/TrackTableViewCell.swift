//
//  TrackTableViewCell.swift
//  QXplayer remote
//
//  Created by Ilya Lagutovsky on 2/4/20.
//  Copyright © 2020 MDSolution. All rights reserved.
//

import UIKit

class TrackTableViewCell: UITableViewCell {

    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var trackName: UILabel!
    
    func setCell(fromList name: String) {
        trackImageView.image = UIImage(named: "default")
        trackName.text = name
    }
    
    func setPreviousFolder() {
        //trackImageView.image = UIImage(named: "default")
        trackName.text = ""
    }
    func setfolder(name: String) {
        trackName.text = name
    }
}
