//
//  CFDPageViewController.swift
//  CFDTabLayout
//
//  Created by Nadiia Ivanova on 31/07/2021.
//

import UIKit

class CFDPageViewController: UIPageViewController {

    lazy var scrollView: UIScrollView? = {
        for subview in view?.subviews ?? [] {
            if let scrollView = subview as? UIScrollView {
                return scrollView
            }
        }
        return nil
    }()

    var currentPage: Int {
        return viewControllers?.first?.view.tag ?? 0
    }
    
    func setSwipe(enabled: Bool) {
        for view in self.view.subviews {
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = enabled
            }
        }
    }
}
