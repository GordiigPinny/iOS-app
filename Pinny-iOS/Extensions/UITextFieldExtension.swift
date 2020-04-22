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
        !(self.text?.isEmpty ?? true)
    }
    
}
