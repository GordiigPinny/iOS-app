//
//  PlaceImageDetailViewController.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 04.05.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit

class PlaceImageDetailViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!

    // MARK: - Variables
    static let id = "PlaceImageDetailVC"
    var imageFile: ImageFile!

    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(accessLevelChanged), name: .accessLevelChanged, object: nil)
        imageView.image = imageFile.image
        accessLevelChanged()
    }

    // MARK: - Actions
    @objc func accessLevelChanged() {
        deleteButton.isHidden = Defaults.currentAccessLevel.rawValue < AccessLevel.admin.rawValue
    }

    @IBAction func deleteButtonPressed(_ sender: Any) {
        presentDefaultOKAlert(title: "Implement me", msg: nil)    
    }

}
