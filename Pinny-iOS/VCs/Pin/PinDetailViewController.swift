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

    // MARK: - Fill view
    private func fillView() {
        if !isViewLoaded { return }
        nameLabel.text = pin.name
        descrLabel.text = pin.descr
        priceButton.setTitle("\(pin.price ?? -1)", for: .normal)
        let imgFile = ImageFile.manager.get(id: pin.picId!)
        if imgFile == nil {
            imageView.image = ImageFile.defaultImage
        } else {
            imageView.image = imgFile!.image
        }
    }

}
