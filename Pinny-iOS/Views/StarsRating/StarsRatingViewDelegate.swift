//
//  StarsRatingViewDelegate.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 21.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation


protocol StarsRatingViewDelegate: class {
    func ratingDidChange(_ starsRatingView: StarsRatingView, newRating rating: UInt)
    
}
