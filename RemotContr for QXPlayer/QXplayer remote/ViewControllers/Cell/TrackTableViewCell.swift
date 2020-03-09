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
    
    func setCell(from name: String?) {
        
//        trackImageView.setImage(with: trackInformation?.imageData)
        trackName.text = name
    }
}
