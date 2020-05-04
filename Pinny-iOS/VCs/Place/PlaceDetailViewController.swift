//
//  PlaceDetailViewController.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 23.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit
import Combine

class PlaceDetailViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var starsRatingView: StarsRatingView!
    @IBOutlet weak var acceptButtonVew: AcceptButtonView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var globalRatingLabel: UILabel!
    @IBOutlet weak var photosButton: UIButton!
    @IBOutlet weak var placeImagesActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var appleMapsButton: UIButton!
    @IBOutlet weak var yandexMapsButton: UIButton!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var acceptTypeLabel: UILabel!
    @IBOutlet weak var checkedByModeratorLabel: UILabel!
    
    // MARK: - Variables
    static let id = "PlaceDetailVC"
    private var placeGetter: PlaceGetter?
    private var _place: Place = Place()
    var place: Place {
        get {
            _place
        }
        set {
            if !newValue.isDetailed {
                getPlace(newValue)
                return
            }
            self._place = newValue
            fillViewController()
        }
    }

    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(accessLevelChanged), name: .accessLevelChanged, object: nil)
        starsRatingView.delegate = self
        acceptButtonVew.delegate = self
        placeImagesActivityIndicator.stopAnimating()
        fillViewController()
    }

    // MARK: - Actions
    @objc func accessLevelChanged() {
        fillViewController()
    }

    @IBAction func editButtonPressed(_ sender: Any) {
    }
    
    @IBAction func photosButtonPressed(_ sender: Any) {
        placeImagesActivityIndicator.startAnimating()
        photosButton.isEnabled = false

        guard let vc = self.storyboard?.instantiateViewController(identifier: PlaceImagesViewController.id)
                as? PlaceImagesViewController else {
            self.presentDefaultOKAlert(title: "Can't instantiate place images vc", msg: nil)
            return
        }
        vc.place = place
        self.navigationController?.pushViewController(vc, animated: true)

        self.placeImagesActivityIndicator.stopAnimating()
        self.photosButton.isEnabled = true
    }
    
    @IBAction func appleMapsButtonPressed(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(identifier: AppleMapsViewController.id)
                as? AppleMapsViewController else {
            presentDefaultOKAlert(title: "Can't instantiate apple maps vc", msg: nil)
            return
        }
        vc.place = place
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func yandexMapsButtonPressed(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(identifier: YandexMapsViewController.id)
                as? YandexMapsViewController else {
            presentDefaultOKAlert(title: "Can't instantiate yandex maps vc", msg: nil)
            return
        }
        vc.place = place
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Request handlers
    private func getPlace(_ place: Place) {
        placeGetter = PlaceGetter()
        placeGetter?.getPlace(place.id!) { entity, error in
            DispatchQueue.main.async {
                if let err = error {
                    self.presentDefaultOKAlert(title: "Error on fetching place", msg: err.localizedDescription)
                    return
                }
                self.place = place
            }
        }
    }
    

    // MARK: - Fill view with values
    private func fillViewController() {
        if !isViewLoaded { return }
        switch Defaults.currentAccessLevel {
        case .anon:
            fillAnonViewController()
            break
        case .admin:
            fillAdminViewController()
            break
        case .moderator, .authorized:
            fillAuthViewController()
            break
        }
    }

    private func fillAuthViewController() {
        title = place.name
        addressLabel.text = place.address
        acceptTypeLabel.text = place.acceptType
        checkedByModeratorLabel.text = place.checkedByModerator! ? "Проверенно модератором" : "Не проверенно модератором" 
        starsRatingView.isHidden = false
        acceptButtonVew.isHidden = false
        globalRatingLabel.text = "\(place.rating ?? 0)"
        starsRatingView.rating = UInt(place.myRating!)
        acceptButtonVew.isAccepted = place.isAcceptedByMe!
        editButton.isEnabled = false
    }

    private func fillAdminViewController() {
        fillAuthViewController()
        editButton.isEnabled = true
    }

    private func fillAnonViewController() {
        fillAuthViewController()
        starsRatingView.isHidden = true
        acceptButtonVew.isHidden = true
    }

}


// MARK: - Stars rating view delegate
extension PlaceDetailViewController: StarsRatingViewDelegate {
    func ratingDidChange(_ starsRatingView: StarsRatingView, newRating rating: UInt) {

    }
}


// MARK: - Accept button delegate
extension PlaceDetailViewController: AcceptButtonDelegate {
    func acceptButtonStateChanged(_ buttonView: AcceptButtonView, newState: Bool) -> Bool {
        return true
    }
}
