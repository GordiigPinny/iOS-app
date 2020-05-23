//
//  UITextFieldExtension.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 22.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation
import UIKit


extension UITextField {
    var isEmpty: Bool {
        self.text?.isEmpty ?? true
    }

    var isEmail: Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: text ?? "")
    }
    
}
