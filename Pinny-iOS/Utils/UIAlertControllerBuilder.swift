//
//  UIAlertViewBuilder.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 22.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation
import UIKit


class UIAlertControllerBuilder {
    // MARK: - Building alert controller (gettable only)
    private(set) var alert: UIAlertController?
    
    // MARK: - Default alerts as class funcs
    class func defaultOkAlert(title: String?, msg: String?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        return alert
    }

    // MARK: - Builder methods
    func begin(title: String?, msg: String?) {
        alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
    }
    
    func clear() {
        alert = nil
    }
    
    func setTitle(_ title: String?) {
        alert?.title = title
    }
    
    func setMessage(_ message: String?) {
        alert?.message = message
    }
    
    func addAction(title: String?, style: UIAlertAction.Style = .default, handler: ((UIAlertAction) -> Void)? = nil) {
        let newAction = UIAlertAction(title: title, style: style, handler: handler)
        alert?.addAction(newAction)
    }
   
}
