//
//  PlaceSearchTableViewCell.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 23.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit


class PlaceSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var placeNamelabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Reuse id
    static let id = "PlacesSearchCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
