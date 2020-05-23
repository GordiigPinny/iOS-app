//
//  PinDetailViewController.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 03.05.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit
import Combine

class PinDetailViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var priceButton: UIButton!
    @IBOutlet weak var descrLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Variables
    static let id = "PinDetailVC"
    private var _pin = Pin()
    var pin: Pin {
        get {
            _pin
        }
        set {
            if newValue.isDetailed {
                _pin = newValue
                fillView()
                return
            }
            _pin = newValue
            fetchPin(newValue)
        }
    }
    private var pinGetter: PinGetter?
    private var buyPinSubscriber: AnyCancellable?
    private var changeCurrentPinSubscriber: AnyCancellable?

    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        fillView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pinGetter?.cancel()
    }

    // MARK: - Actions
    @IBAction func priceButtonPressed(_ sender: Any) {
        if priceButton.titleLabel?.text == "Выбрать как текущий" {
            changeCurrentPin(self.pin)
            return
        }
        buyPin(self.pin)
    }

    // MARK: - Requests handlers
    private func fetchPin(_ pin: Pin) {
        pinGetter = PinGetter()
        pinGetter?.getPin(pin.id!, completion: getPinCompletion, imageCompletion: getPinImageCompletion)
    }

    private func getPinCompletion(_ pin: Pin?, _ err: PinGetter.ApiError?) {
        DispatchQueue.main.async {
            if let err = err {
                self.presentDefaultOKAlert(title: "Error on fetching pin", msg: err.localizedDescription)
            }
            self.pin = pin!
        }
    }

    private func getPinImageCompletion(_ imageFile: ImageFile?, _ image: UIImage?, _ err: ImageFileRequester.ApiError?) {
        DispatchQueue.main.async {
            if let err = err {
                self.presentDefaultOKAlert(title: "Error on getting image for pin", msg: err.localizedDescription)
            }
            imageFile?.image = image
            self.imageView.image = image
        }
    }

    private func buyPin(_ pin: Pin) {
        priceButton.isEnabled = false
        activityIndicator.startAnimating()
        buyPinSubscriber = GatewayRequester.buyPin(pin: pin)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.priceButton.isEnabled = true
                self.activityIndicator.stopAnimating()
                switch completion {
                case .failure(let err):
                    self.buyPinCompletion(nil, err)
                case .finished:
                    break
                }
            }, receiveValue: { profile in
                self.buyPinCompletion(profile, nil)
            })
    }

    private func buyPinCompletion(_ profile: Profile?, _ err: GatewayRequester.ApiError?) {
        if let err = err {
            self.presentDefaultOKAlert(title: "Error on buying pin", msg: err.localizedDescription)
            return
        }
        fillView()
    }

    private func changeCurrentPin(_ pin: Pin) {
        changeCurrentPinSubscriber = ProfileRequester().changeCurrentPin(pin)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let err):
                    self.changeCurrentPinCompletion(nil, err)
                case .finished:
                    break
                }
            }, receiveValue: { entity in
                Profile.manager.currentProfile = entity
                self.changeCurrentPinCompletion(entity, nil)
            })
    }

    private func changeCurrentPinCompletion(_ profile: Profile?, _ err: ProfileRequester.ApiError?) {
        if let err = err {
            self.presentDefaultOKAlert(title: "Error on changing current pin", msg: err.localizedDescription)
            return
        }
        fillView()
    }

    // MARK: - Fill view
    private func fillView() {
        if !isViewLoaded { return }
        nameLabel.text = pin.name
        descrLabel.text = pin.descr
        let profile = Profile.manager.currentProfile!
        if profile.unlockedPinsId.contains(pin.id!) {
            if profile.geopinSpriteId == pin.id || profile.pinSpriteId == pin.id {
                priceButton.isEnabled = false
                priceButton.setTitle("Выбран как текущий", for: .disabled)   
            } else {
                priceButton.setTitle("Выбрать как текущий", for: .normal)
            }
        } else {
            priceButton.isEnabled = true
            priceButton.setTitle("Купить за \(pin.price ?? -1)", for: .normal)
        }
        let imgFile = ImageFile.manager.get(id: pin.picId!)
        if imgFile == nil {
            imageView.image = ImageFile.defaultImage
        } else {
            imageView.image = imgFile!.image
        }
    }

}
