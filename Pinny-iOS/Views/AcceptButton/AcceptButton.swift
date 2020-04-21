//
//  AcceptButton.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 21.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit


class AcceptButton: UIButton {
    // MARK: - Enums
    enum AcceptButtonState {
        case accepted
        case notAccepted
    }
    
    // MARK: - Variables
    var acceptState: AcceptButtonState = .notAccepted {
        didSet {
            switch acceptState {
            case .accepted:
                backgroundColor = .red
                titleLabel?.text = "Удалить подтверждение существования"
            case .notAccepted:
                backgroundColor = .green
                titleLabel?.text = "Подтвердить существование"
            }
        }
    }
    
    // MARK: - Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
