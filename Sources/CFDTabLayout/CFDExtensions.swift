//
//  CFDExtensions.swift
//  CFDTabLayout
//
//  Created by Nadiia Ivanova on 31/07/2021.
//

import UIKit
import Foundation

extension UIView {
    var parentViewController: UIViewController? {
            var parentResponder: UIResponder? = self
            while parentResponder != nil {
                parentResponder = parentResponder?.next
                if let viewController = parentResponder as? UIViewController {
                    return viewController
                }
            }
            return nil
        }
}
