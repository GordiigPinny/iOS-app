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
    
    // MARK: - Variables
    static let id = "PlaceDetailVC"
    var placeSubscriber: AnyCancellable?
    private var _place: Place = Place()
    var place: Place {
        get {
            _place
        }
        set {
            if !newValue.isDetailed {
                placeSubscriber = Place.manager.fetch(id: newValue.id!)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .failure(let err):
                            self.placeGetFailure(err)
                        case .finished:
                            break
                        }
                    }, receiveValue: { place in
                        self.placeGetSuccess(place)
                    })
                return
            }
            self._place = newValue
            fillViewController()
        }
    }

    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        starsRatingView.delegate = self
        acceptButtonVew.delegate = self
        placeImagesActivityIndicator.stopAnimating()
        fillViewController()
    }

    // MARK: - Actions
    @IBAction func photosButtonPressed(_ sender: Any) {
        placeImagesActivityIndicator.startAnimating()
        photosButton.isEnabled = false
        DispatchQueue.main.asyncAfter(wallDeadline: .now()) {
            self.placeImagesActivityIndicator.stopAnimating()
            self.photosButton.isEnabled = true
            guard let vc = self.storyboard?.instantiateViewController(identifier: PlaceImagesViewController.id)
                    as? PlaceImagesViewController else {
                self.presentDefaultOKAlert(title: "Can't instantiate place images vc", msg: nil)
                return
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - Fill view with values
    private func fillViewController() {
        if !isViewLoaded { return }
        title = place.name
        addressLabel.text = place.address
        globalRatingLabel.text = "\(place.rating ?? 0)"
        starsRatingView.rating = UInt(place.myRating!)
        acceptButtonVew.isAccepted = place.isAcceptedByMe!
    }

    private func placeGetSuccess(_ place: Place) {
        _place = place
        fillViewController()
    }

    private func placeGetFailure(_ err: PlaceRequester.ApiError) {
        presentDefaultOKAlert(title: "Error on fetching place", msg: err.localizedDescription)
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
