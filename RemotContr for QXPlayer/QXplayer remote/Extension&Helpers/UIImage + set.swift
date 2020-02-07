//
//  UIImage + set.swift
//  QXplayer remote
//
//  Created by Ilya Lagutovsky on 2/7/20.
//  Copyright © 2020 MDSolution. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    func setImage(with data: Data?) {
        if let data = data, let image = UIImage(data: data) {
            self.image = image
        } else {
            self.image = UIImage()
        }
    }
    
}
