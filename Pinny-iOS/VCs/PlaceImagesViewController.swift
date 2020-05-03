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

    // MARK: - Variables
    static let id = "PlaceImagesVC"
    var itemsPerRow: CGFloat = 3
    var sectionInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    var imageFilesSubscriber: AnyCancellable?
    var downloadTasks = [URLSessionDownloadTask]()
    private var _place = Place()
    var imagesToShow = [ImageFile]()
    var place: Place {
        get {
            _place
        }
        set {
            let imageRequester = ImageFileRequester()
            imageRequester.resourcePostfix = "place/\(newValue.id!)/"
            self.imageFilesSubscriber = imageRequester.getList()
                .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let err):
                    self.imageFilesGetFailure(err)
                case .finished:
                    break
                }
            }, receiveValue: { entities in
                self.imageFilesGetSuccess(entities)
            })
        }
    }

    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        downloadTasks.forEach { $0.cancel() }
        downloadTasks = []
    }

    // MARK: - Request handlers
    private func imageFilesGetSuccess(_ imageFiles: [ImageFile]) {
        self.imagesToShow = imageFiles
        for entity in imageFiles {
            let requester = URLRequester(host: Hosts.mediaHostNoApiUrl)
            guard var imageUrl = entity.imageUrl else {
                continue
            }
            imageUrl.removeFirst()
            let dwTask = requester.download(urlPostfix: imageUrl, forObject: entity,
                    completionHandler: self.imagesGetCompletion)
            self.downloadTasks.append(dwTask)
        }
    }

    private func imageFilesGetFailure(_ err: ImageFileRequester.ApiError) {
        presentDefaultOKAlert(title: "Error on getting image files", msg: "")
    }

    private func imagesGetCompletion(_ place: Any?, _ image: UIImage?, _ err: URLRequester.RequestError?) {
        DispatchQueue.main.async {
            if let err = err {
                self.presentDefaultOKAlert(title: "Error on getting image", msg: err.localizedDescription)
                return
            }
            (place as! ImageFile).image = image
            if self.isViewLoaded {
                self.collectionView.reloadData()
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

}
