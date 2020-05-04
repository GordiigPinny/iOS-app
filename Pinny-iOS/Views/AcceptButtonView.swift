//
//  AcceptButton.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 21.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit


@IBDesignable
class AcceptButtonView: UIView {
    // MARK: - Variables
    weak var delegate: AcceptButtonDelegate?
    var button = UIButton()
    var activityIndicator = UIActivityIndicatorView()
    
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
        // Button init
        button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.setTitle("Удалить подтверждение сущестования", for: .selected)
        button.setTitle("Удалить подтверждение сущестования", for: [.selected, .highlighted])
        button.setTitle("Удалить подтверждение сущестования", for: [.selected, .disabled])
        button.setTitle("Подтвердить существование", for: .normal)
        button.setTitleColor(.red, for: .selected)
        button.setTitleColor(.red, for: [.selected, .highlighted])
        button.setTitleColor(.gray, for: [.selected, .disabled])
        button.setTitleColor(.green, for: .normal)
        button.setTitleColor(.gray, for: [.normal, .disabled])
        button.tintColor = .clear
        button.addTarget(self, action: #selector(self.buttonPressed), for: .touchUpInside)
        self.addSubview(button)
        
        // Refresh control init
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        self.addSubview(activityIndicator)
        
        // Constraints init
        self.addConstraints([
            NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: button, attribute: .height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: button, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: activityIndicator, attribute: .leading, relatedBy: .equal, toItem: button, attribute: .trailing, multiplier: 1, constant: 3)
        ])
        
        isAccepted = false
    }
    
    // MARK: - Inspectables
    @IBInspectable var isAccepted: Bool {
        get {
            button.isSelected
        }
        set {
            button.isSelected = newValue
        }
    }
    
    // MARK: - Touch targets
    @objc func buttonPressed(_ button: UIButton) {
        startAnimating()
        self.delegate?.acceptButtonStateWillChange(self, newState: !self.isAccepted)
        self.endAnimating()
    }

    // MARK: - Activity indicator manipulations
    func startAnimating() {
        self.activityIndicator.startAnimating()
        button.isEnabled = false
    }
    
    func endAnimating() {
        self.activityIndicator.stopAnimating()
        button.isEnabled = true
    }
}


protocol AcceptButtonDelegate: class {
    func acceptButtonStateWillChange(_ buttonView: AcceptButtonView, newState: Bool)
}
