//
//  PlaceImagesViewController.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 03.05.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit
import Combine

class PlaceImagesViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var uploadActivityIndicator: UIActivityIndicatorView!
    
    // MARK: - Variables
    static let id = "PlaceImagesVC"
    var itemsPerRow: CGFloat = 3
    var sectionInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    private var imageGetter: ImageGetter?
    private var uploadTask: URLSessionUploadTask?
    private var _place = Place()
    var imagesToShow = [ImageFile]()
    var place: Place {
        get {
            _place
        }
        set {
            getImages(newValue)
            _place = newValue
        }
    }

    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(accessLevelChanged), name: .accessLevelChanged, object: nil)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        accessLevelChanged()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imageGetter?.cancel()
    }

    // MARK: - Actions
    @objc func accessLevelChanged() {
        addButton.isEnabled = Defaults.currentAccessLevel.rawValue >= AccessLevel.moderator.rawValue
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            presentDefaultOKAlert(title: "Can't open photo library", msg: "Maybe app hasn't permissions to do so")    
            return
        }
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.sourceType = .photoLibrary
        vc.mediaTypes = ["public.image"]
        vc.allowsEditing = false
        self.present(vc, animated: true)
    }
    

    // MARK: - Request handlers
    private func getImages(_ place: Place) {
        imageGetter = ImageGetter()
        imagesToShow = []
        imageGetter?.getImagesFor(place: place) { entity, image, error in
            DispatchQueue.main.async {
                if let err = error {
                    self.presentDefaultOKAlert(title: "Error on getting image", msg: err.localizedDescription)
                    return
                }
                entity?.image = image
                self.imagesToShow.append(entity!)
                if self.isViewLoaded {
                    self.collectionView.reloadData()
                }
            }
        }
    }

}


// MARK: - Collection view data source
extension PlaceImagesViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imagesToShow.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaceImageCollectionViewCell.id,
                for: indexPath) as? PlaceImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.placeImageView.image = imagesToShow[indexPath.item].image
        return cell
    }

}


// MARK: - Collection view layout delegate
extension PlaceImagesViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        sectionInsets.left
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                               minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        sectionInsets.left
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = imagesToShow[indexPath.item]
        guard let vc = storyboard?.instantiateViewController(identifier: PlaceImageDetailViewController.id)
                as? PlaceImageDetailViewController else {
            presentDefaultOKAlert(title: "Can't instantiate image detail vc", msg: nil)
            return
        }
        vc.imageFile = image
        vc.callingVC = self
        present(vc, animated: true)
    }
}


// MARK: - Image picker delegate
extension PlaceImagesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            presentDefaultOKAlert(title: "Error on picking image", msg: "Can't cast it to UIImage")
            return
        }
        picker.dismiss(animated: true)
        self.uploadActivityIndicator.startAnimating()
        self.collectionView.isUserInteractionEnabled = false
        let requester = URLRequester(host: Hosts.mediaHostUrl)
        self.uploadTask = requester.upload(urlPostfix: "images/", image: image, objectType: .place, objectId: place.id!) { file, error in
            DispatchQueue.main.async {
                self.uploadActivityIndicator.stopAnimating()
                self.collectionView.isUserInteractionEnabled = true
                if let err = error {
                    self.presentDefaultOKAlert(title: "Error on uploading image", msg: err.localizedDescription)
                    return
                }
                ImageFile.manager.addLocaly(file!)
                self.imagesToShow.append(file!)
                self.getImages(self.place)
            }
        }
    }

}

