//
//  PlaceImageDetailViewController.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 04.05.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit
import Combine

class PlaceImageDetailViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Variables
    static let id = "PlaceImageDetailVC"
    var imageFile: ImageFile!
    private var deleteSubscriber: AnyCancellable?
    var callingVC: PlaceImagesViewController!

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
        activityIndicator.startAnimating()
        deleteSubscriber = ImageFileRequester().deleteObject(imageFile.id!)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.activityIndicator.stopAnimating()
                switch completion {
                case .failure(let err):
                    self.deleteCompletion(nil, err)
                case .finished:
                    break
                }
            }, receiveValue: { b in
                self.deleteCompletion(b, nil)
            })
    }

    private func deleteCompletion(_ didDelete: Bool?, _ err: ImageFileRequester.ApiError?) {
        if let err = err {
            self.presentDefaultOKAlert(title: "Error on deleting image", msg: err.localizedDescription)
            return
        }
        if !(didDelete!) {
            self.presentDefaultOKAlert(title: "Image is not deleted", msg: nil)
            return
        }
        ImageFile.manager.delete(self.imageFile)
        callingVC.imagesToShow.removeAll { $0.id == self.imageFile.id }
        callingVC.collectionView.reloadData()
        self.dismiss(animated: true)
    }

}
