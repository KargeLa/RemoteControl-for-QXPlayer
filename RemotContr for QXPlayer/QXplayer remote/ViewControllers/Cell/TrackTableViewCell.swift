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
    
    func setCell(from trackInformation: TrackInformation?) {
        guard let trackInformation = trackInformation, let image = UIImage(data: trackInformation.imageData) else { return }
        
        trackImageView.image = image
        trackName.text = trackInformation.trackName
    }
}
