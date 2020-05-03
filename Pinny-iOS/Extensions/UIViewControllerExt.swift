//
//  UIViewControllerExt.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 22.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController {
    func isTextFieldEmpty(_ textField: UITextField) -> Bool {
        return textField.isEmpty
    }

    func presentDefaultOKAlert(title: String, msg: String?) {
        let alert = UIAlertControllerBuilder.defaultOkAlert(title: title, msg: msg)
        present(alert, animated: true)
    }
    
}
