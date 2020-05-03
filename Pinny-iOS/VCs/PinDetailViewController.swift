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
    var pinSubscriber: AnyCancellable?
    var imageFileSubscriber: AnyCancellable?
    var dwTask: URLSessionDownloadTask?

    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        fillView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dwTask?.cancel()
    }

    // MARK: - Actions
    @IBAction func priceButtonPressed(_ sender: Any) {

    }

    // MARK: - Requests handlers
    private func fetchPin(_ pin: Pin) {
        pinSubscriber = Pin.manager.fetch(id: pin.id!)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let err):
                    self.fetchPinFailure(err)
                case .finished:
                    break
                }
            }, receiveValue: { pin in
                self.fetchPinSuccess(pin)
            })
    }

    private func fetchPinSuccess(_ pin: Pin) {
        self.pin = pin
        imageFileSubscriber = ImageFile.manager.fetch(id: pin.picId!)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let err):
                    self.fetchImageFileFailure(err)
                case .finished:
                    break
                }
            }, receiveValue: { file in
                self.fetchImageFileSuccess(file)
            })
    }

    private func fetchPinFailure(_ err: PinRequester.ApiError) {
        presentDefaultOKAlert(title: "Error on fetching pin", msg: err.localizedDescription)
    }

    private func fetchImageFileSuccess(_ imageFile: ImageFile) {
        let requester = URLRequester(host: Hosts.mediaHostNoApiUrl)
        dwTask = requester.download(urlPostfix: imageFile.imageUrlForPostfix, forObject: imageFile,
                completionHandler: self.getImageCompletion)
    }

    private func fetchImageFileFailure(_ err: ImageFileRequester.ApiError) {
        presentDefaultOKAlert(title: "Error on fetching image file", msg: err.localizedDescription)
    }

    private func getImageCompletion(_ imageFile: Any?, _ image: UIImage?, _ err: URLRequester.RequestError?) {
        DispatchQueue.main.async {
            if let err = err {
                self.presentDefaultOKAlert(title: "Error on getting image", msg: err.localizedDescription)
                return
            }
            (imageFile as! ImageFile).image = image
            self.fillView()
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
