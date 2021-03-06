//
//  AchievementTableViewCell.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 03.05.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit

class AchievementTableViewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var markImageView: UIImageView!
    
    // MARK: - Variables
    static let id = "AchievementTableViewCell"
    
    // MARK: - Set up code
    func setUp(_ achievement: Achievement) {
        nameLabel.text = achievement.name
        markImageView.image = UIImage(systemName: "xmark")
        if let profile = Profile.manager.currentProfile {
            if profile.achievementsId.contains(achievement.id!) {
                markImageView.image = UIImage(systemName: "checkmark")
            }
        }
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
