//
//  PinTableViewCell.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 03.05.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit

class PinTableViewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    // MARK: - Variables
    static let id = "PinTableViewCell"

    // MARK: - Set up code
    func setUp(_ pin: Pin) {
        nameLabel.text = pin.name
        priceLabel.text = "Price: \(pin.price ?? -1)"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
