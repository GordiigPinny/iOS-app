//
//  PlaceDetailViewController.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 23.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit

class PlaceDetailViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var starsRatingView: StarsRatingView!
    @IBOutlet weak var acceptButtonVew: AcceptButtonView!

    // MARK: - Variables
    static let id = "PlaceDetailVC"
    var place: Place?

    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}


extension PlaceDetailViewController: AcceptButtonDelegate {
    func acceptButtonStateChanged(_ buttonView: AcceptButtonView, newState: Bool) -> Bool {
        return true
    }
}
