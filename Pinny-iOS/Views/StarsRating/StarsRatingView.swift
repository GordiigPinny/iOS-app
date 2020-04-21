//
//  StarsRatingView.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 21.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit

class StarsRatingView: UIView {
    
    // MARK: - Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var starsStackView: UIStackView!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    @IBOutlet weak var fourthButton: UIButton!
    @IBOutlet weak var fifthButton: UIButton!
    
    // MARK: - Variables
    weak var delegate: StarsRatingViewDelegate? = nil
    
    // MARK: - Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("StarsRatingView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    
    // MARK: - Actions
    
    @IBAction func firstButtonPressed(_ sender: Any) {
        delegate?.ratingDidChange(self, newRating: 1)
    }
    
    @IBAction func secondButtonPressed(_ sender: Any) {
        delegate?.ratingDidChange(self, newRating: 2)
    }
    
    @IBAction func thirdButtonPressed(_ sender: Any) {
        delegate?.ratingDidChange(self, newRating: 3)
    }
    
    @IBAction func fourthButtonPressed(_ sender: Any) {
        delegate?.ratingDidChange(self, newRating: 4)
    }
    
    @IBAction func fifthButtonPressed(_ sender: Any) {
        delegate?.ratingDidChange(self, newRating: 5)
    }
    
}
