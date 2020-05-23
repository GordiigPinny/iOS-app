//
//  StatsTableViewCell.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 04.05.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit

class StatsTableViewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var methodLabel: UILabel!
    @IBOutlet weak var endpointLabel: UILabel!
    @IBOutlet weak var processTimeLabel: UILabel!
    
    // MARK: - Variables
    static let id = "StatsTableViewCell"

    // MARK: - Set up
    func setUp(_ stat: RequestStats) {
        methodLabel.text = stat.method.rawValue + " \(stat.statusCode!)"
        endpointLabel.text = stat.endpoint
        processTimeLabel.text = "Process time: \(stat.processTime!)"
        userLabel.text = stat.userId == nil ? "Anon" : "User \(stat.userId!)"
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
