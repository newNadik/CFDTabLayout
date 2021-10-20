//
//  CFDTabLayoutProtocol.swift
//  
//
//  Created by Nadiia Ivanova on 03/08/2021.
//

import UIKit
import Foundation

@objc public protocol CFDTabLayoutProtocol: NSObjectProtocol {
 
    func numberOfPages(in tabLayout: CFDTabLayout) -> Int
    @objc optional func tabLayout(_ tabLayout: CFDTabLayout, viewControllerAt index: Int) -> UIViewController?
    func tabLayout(_ tabLayout: CFDTabLayout, titleAt index: Int) -> String
    @objc optional func tabLayout(_ tabLayout: CFDTabLayout, didSelectTab index: Int)
    
}
