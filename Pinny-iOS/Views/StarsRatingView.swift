//
//  StarsRatingView.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 21.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit


@IBDesignable
class StarsRatingView: UIStackView {
    // MARK: - Variables
    weak var delegate: StarsRatingViewDelegate? = nil
    private var buttonsArr = [UIButton]()
    private var innerLeadingConstraint = NSLayoutConstraint()
    private var innerTrailingConstraint = NSLayoutConstraint()
    
    // MARK: - Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let configuration = UIImage.SymbolConfiguration(pointSize: 20)
        let starImage = UIImage(systemName: "star", withConfiguration: configuration)!
        let starFilledImage = UIImage(systemName: "star.fill", withConfiguration: configuration)!
        self.axis = .horizontal
        self.distribution = .equalSpacing
        self.spacing = 8
        for button in buttonsArr {
            self.removeArrangedSubview(button)
        }
        removeConstraints([innerLeadingConstraint, innerTrailingConstraint])
        buttonsArr = []
        for _ in 0 ..< 5 {
            let button = UIButton()
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            button.addTarget(self, action: #selector(self.buttonPressed), for: .touchUpInside)
            button.addTarget(self, action: #selector(self.buttonIsPressedNow), for: .touchDown)
            button.addTarget(self, action: #selector(self.buttonPressDissmised), for: .touchUpOutside)
            button.setImage(starImage, for: .normal)
            button.setImage(starFilledImage, for: .selected)
            button.setImage(starFilledImage, for: [.selected, .highlighted])
            addArrangedSubview(button)
            buttonsArr.append(button)
        }
        innerLeadingConstraint = NSLayoutConstraint(item: buttonsArr[0], attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        innerTrailingConstraint = NSLayoutConstraint(item: buttonsArr.last!, attribute: .trailing, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        self.addConstraints([innerLeadingConstraint, innerTrailingConstraint])
        fillStars(to: self.rating)
    }
    
    // MARK: - Inspectables
    @IBInspectable var rating: UInt = 0 {
        didSet {
            fillStars(to: rating)
        }
    }
    
    // MARK: - Actions
    @objc func buttonPressed(_ button: UIButton) {
        guard let idx = buttonsArr.firstIndex(of: button) else {
            fatalError("Unknown button was pressed")
        }
        let oldRating = self.rating
        let newRating = UInt(idx + 1)
        self.delegate?.ratingWillChange(self, oldRating: oldRating, newRating: newRating)
    }
    
    @objc func buttonIsPressedNow(_ button: UIButton) {
        guard let idx = buttonsArr.firstIndex(of: button) else {
            fatalError("Unknown button was pressed")
        }
        let rating = UInt(idx + 1)
        self.fillStars(to: rating)
    }
    
    @objc func buttonPressDissmised(_ button: UIButton) {
        self.fillStars(to: self.rating)
    }
    
    // MARK: - Fill stars before tapped
    private func fillStars(to newRating: UInt) {
        for (i, button) in buttonsArr.enumerated() {
            button.isSelected = i < newRating
        }
    }
    
}


// MARK: - Delegate protocol
protocol StarsRatingViewDelegate: class {
    func ratingWillChange(_ starsRatingView: StarsRatingView, oldRating: UInt, newRating rating: UInt)
    
}
