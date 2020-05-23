//
// Created by Dmitry Gorin on 18.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation
import UIKit
import Combine


class AvatarChanger {
    typealias ApiError = ProfileRequester.ApiError
    typealias Completion = (ImageFile?, Profile?, ApiError?) -> Void

    var imageUploadTask: URLSessionUploadTask?
    var profileChangeSubscriber: AnyCancellable?

    var profile: Profile
    var image: UIImage

    init(profile: Profile, image: UIImage) {
        self.profile = profile
        self.image = image
    }

    func changeAvatar(completion: Completion? = nil) {
        let requester = URLRequester(host: Hosts.mediaHostUrl)
        imageUploadTask = requester.upload(urlPostfix: "images/", image: image, objectType: .user, objectId: profile.userId) { imageFile, error in
            // Error in image upload
            if let err = error {
                switch err {
                case .requestError(let reqErr):
                    completion?(nil, nil, ApiError.requestError(err: reqErr))
                case .decodeError:
                    completion?(nil, nil, ApiError.decodeError(type: Profile.self))
                }
                return
            }

            // Changing profile
            let profileRequester = ProfileRequester()
            self.profileChangeSubscriber = profileRequester.changeAvatarId(imageFile?.id)
                .sink(receiveCompletion: { c in
                    switch c {
                    case .failure(let err):
                        completion?(nil, nil, err)
                    case .finished:
                        break
                    }
                }, receiveValue: { entity in
                    completion?(imageFile, entity, nil)
                })
        }
    }


}
