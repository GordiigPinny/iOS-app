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
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteActivityIndicator: UIActivityIndicatorView!
    
    // MARK: - Variables
    static let id = "PlaceDetailVC"
    private var placeGetter: PlaceGetter?
    private var ratingChangeSubscriber: AnyCancellable?
    private var acceptChangeSubscriber: AnyCancellable?
    private var placeDeleteSubscriber: AnyCancellable?
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        placeGetter?.cancel()
        ratingChangeSubscriber?.cancel()
        acceptChangeSubscriber?.cancel()
        placeDeleteSubscriber?.cancel()
    }

    // MARK: - Actions
    @objc func accessLevelChanged() {
        fillViewController()
    }

    @IBAction func editButtonPressed(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(identifier: EditPlaceViewController.id)
                as? EditPlaceViewController else {
            presentDefaultOKAlert(title: "Can't instantiate edit place vc", msg: nil)
            return
        }
        vc.place = place
        vc.calleeVc = self
        present(vc, animated: true)
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
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        deleteButton.isEnabled = false
        deleteActivityIndicator.startAnimating()
        placeDeleteSubscriber = Place.manager.deleteRemotely(place)
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            self.deleteActivityIndicator.stopAnimating()
            self.deleteButton.isEnabled = true
            switch completion {
            case .failure(let err):
                self.presentDefaultOKAlert(title: "Error on deleting place", msg: err.localizedDescription)
            case .finished:
                break
            }
        }, receiveValue: { b in
            if !b {
                self.presentDefaultOKAlert(title: "Didn't delete this place", msg: "Dunno why tho")
            }
            self.navigationController?.popToRootViewController(animated: true)
        })
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
        starsRatingView.isHidden = false
        acceptButtonVew.isHidden = false
        globalRatingLabel.text = "\(place.rating ?? 0)"
        starsRatingView.rating = UInt(place.myRating!)
        acceptButtonVew.isAccepted = place.isAcceptedByMe!
        editButton.isEnabled = false
        deleteButton.isHidden = true
    }

    private func fillAdminViewController() {
        fillAuthViewController()
        editButton.isEnabled = true
        deleteButton.isHidden = false
        if place.deletedFlg {
            deleteButton.isEnabled = false
            deleteButton.setTitleColor(UIColor.gray, for: .disabled)
        } else {
            deleteButton.isEnabled = false
        }
    }

    private func fillAnonViewController() {
        fillAuthViewController()
        starsRatingView.isHidden = true
        acceptButtonVew.isHidden = true
    }

}


// MARK: - Stars rating view delegate
extension PlaceDetailViewController: StarsRatingViewDelegate {
    func ratingWillChange(_ starsRatingView: StarsRatingView, oldRating: UInt, newRating rating: UInt) {
        changeRating(self.place, rating)
    }

    private func changeRating(_ place: Place, _ newRating: UInt) {
        ratingChangeSubscriber = GatewayRequester.updateRating(placeId: place.id!, rating: Int(newRating))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let err):
                    self.changeRatingCompletion(nil, nil, err)
                case .finished:
                    break
                }
            }, receiveValue: { rating, profile in
                self.changeRatingCompletion(rating, profile, nil)
            })
    }

    private func changeRatingCompletion(_ rating: Rating?, _ profile: Profile?, _ err: GatewayRequester.ApiError?) {
        if let err = err {
            self.presentDefaultOKAlert(title: "Error on changing rating", msg: err.localizedDescription)
            starsRatingView.rating = starsRatingView.rating
            return
        }
        starsRatingView.rating = UInt(rating!.rating!)
        self.globalRatingLabel.text = "\(self.place.rating!)"
        if profile == nil {
            self.presentDefaultOKAlert(title: "Rating changed", msg: "But profile didn't update")
            return
        }
    }

}


// MARK: - Accept button delegate
extension PlaceDetailViewController: AcceptButtonDelegate {
    func acceptButtonStateWillChange(_ buttonView: AcceptButtonView, newState: Bool) {
        newState ? addAccept(self.place) : deleteAccept(self.place)
    }

    private func addAccept(_ place: Place) {
        acceptButtonVew.button.isEnabled = false
        acceptChangeSubscriber = GatewayRequester.addAccept(place: place)
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            self.acceptButtonVew.button.isEnabled = true
            switch completion {
            case .failure(let err):
                self.addAcceptCompletion(nil, nil, err)
            case .finished:
                break
            }
        }, receiveValue: { accept, profile in
            self.addAcceptCompletion(accept, profile, nil)
        })
    }

    private func addAcceptCompletion(_ accept: Accept?, _ profile: Profile?, _ err: GatewayRequester.ApiError?) {
        if let err = err {
            self.presentDefaultOKAlert(title: "Error on adding accept", msg: err.localizedDescription)
            return
        }
        acceptButtonVew.isAccepted = true
        place.isAcceptedByMe = true
        self.acceptTypeLabel.text = "\(place.acceptType!)"
        if profile == nil {
            self.presentDefaultOKAlert(title: "Added accept", msg: "But didn't update profile")
            return
        }
        Profile.manager.currentProfile = profile!
    }

    private func deleteAccept(_ place: Place) {
        let accept_ = Accept.manager.entities.last { accept in
            accept.placeId == place.id && accept.createdById == User.manager.currentUser?.id
        }
        guard let accept = accept_ else {
            self.presentDefaultOKAlert(title: "No accept here", msg: nil)
            return
        }
        acceptButtonVew.button.isEnabled = false
        acceptChangeSubscriber = GatewayRequester.deleteAccept(acceptId: accept.id!)
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            self.acceptButtonVew.button.isEnabled = true
            switch completion {
            case .failure(let err):
                self.deleteAcceptCompletion(nil, err)
            case .finished:
                break
            }
        }, receiveValue: { profile in
            self.deleteAcceptCompletion(profile, nil)
        })
    }

    private func deleteAcceptCompletion(_ profile: Profile?, _ err: GatewayRequester.ApiError?) {
        if let err = err {
            self.presentDefaultOKAlert(title: "Error on deleting accept", msg: err.localizedDescription)
            return
        }
        acceptButtonVew.isAccepted = false
        place.isAcceptedByMe = false
        self.acceptTypeLabel.text = "\(place.acceptType!)"
//        if profile == nil {
//            self.presentDefaultOKAlert(title: "Deleted accept", msg: "But didn't update profile")
//            return
//        }
        let p = Profile.manager.currentProfile!
        p.money += 100
        p.rating += 50
        if !p.achievementsId.contains(5) {
            p.achievementsId.append(5)
        }
        Profile.manager.currentProfile = p
    }

}
