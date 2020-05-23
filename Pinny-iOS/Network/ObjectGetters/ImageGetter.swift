//
// Created by Dmitry Gorin on 04.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation
import UIKit
import Combine

class ImageGetter {
    typealias Entity = ImageFile
    typealias Completion = ((Entity?, UIImage?, ImageFileRequester.ApiError?) -> Void)?

    private var imageFileSubscriber: AnyCancellable?
    private var imageFilesSubscriber: AnyCancellable?
    private var imageDwTask: URLSessionDownloadTask?
    private var imageDwTasks = [URLSessionDownloadTask]()

    deinit {
        cancel()
    }

    func cancel() {
        imageFileSubscriber?.cancel()
        imageFilesSubscriber?.cancel()
        imageDwTask?.cancel()
        imageDwTasks.forEach { $0.cancel() }
    }

    func getAvatar(profile: Profile, completion: Completion = nil) {
        if profile.picId != nil {
            getImage(id: profile.picId!, completion: completion)
        }
    }

    func getPinImage(pin: Pin, completion: Completion = nil) {
        if pin.picId != nil {
            getImage(id: pin.picId!, completion: completion)
        }
    }

    func getAchievementImage(achievement: Achievement, completion: Completion = nil) {
        if achievement.picId != nil {
            getImage(id: achievement.picId!, completion: completion)
        }
    }

    func getImage(id: ImageFile.ID, completion: Completion = nil) {
        imageFileSubscriber = ImageFile.manager.fetch(id: id)
            .sink(receiveCompletion: { c in
                switch c {
                case .failure(let err):
                    self.imageFileGetFailure(err, completion)
                case .finished:
                    break
                }
            }, receiveValue: { entity in
                self.imageFileGetSuccess(entity, completion)
            })
    }

    func getImagesFor(place: Place, completion: Completion = nil) {
        if place.id == nil { return }
        let requester = ImageFileRequester()
        requester.resourcePostfix = "place/\(place.id!)/"
        imageFilesSubscriber = requester.getList()
            .sink(receiveCompletion: { c in
                switch c {
                case .failure(let err):
                    self.imageFileGetFailure(err, completion)
                case .finished:
                    break
                }
            }, receiveValue: { entities in
                self.imageFilesGetSuccess(entities, completion)
            })

    }

    private func imageFileGetSuccess(_ imageFile: ImageFile, _ completion: Completion) {
        ImageFile.manager.replace(imageFile, with: imageFile)
        let requester = URLRequester(host: Hosts.mediaHostNoApiUrl)
        imageDwTask = requester.download(urlPostfix: imageFile.imageUrlForPostfix, forObject: imageFile,
                completionHandler: completion)
    }

    private func imageFileGetFailure(_ err: ImageFileRequester.ApiError, _ completion: Completion) {
        completion?(nil, nil, err)
    }

    private func imageFilesGetSuccess(_ imageFiles: [ImageFile], _ completion: Completion) {
        imageFiles.forEach { ImageFile.manager.addLocaly($0) }
        let requester = URLRequester(host: Hosts.mediaHostNoApiUrl)
        for imageFile in imageFiles {
            let dwTask = requester.download(urlPostfix: imageFile.imageUrlForPostfix, forObject: imageFile,
                    completionHandler: completion)
            imageDwTasks.append(dwTask)
        }
    }

}
