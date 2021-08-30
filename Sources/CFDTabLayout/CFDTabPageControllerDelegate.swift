//
//  File.swift
//  
//
//  Created by Nadiia Ivanova on 05/08/2021.
//

import UIKit
import Foundation

enum NavigationDirection {
    case stopped
    case right
    case left
}

extension CFDTabLayout: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = viewController.view.tag
        let newIndex = currentIndex - 1
        if(newIndex >= 0) {
            return viewControllerAt(index: newIndex)
        }
        return nil
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = viewController.view.tag
        let newIndex = currentIndex + 1
        if(newIndex < (delegate?.numberOfPages(in: self) ?? 0)) {
            return viewControllerAt(index: newIndex)
        }
        return nil
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        pendingIndex = pendingViewControllers.first?.view.tag ?? 0
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            currentPage = pendingIndex
        }
    }
    
}

extension CFDTabLayout: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView != pageController.scrollView) {
            return
        }
        var direction = NavigationDirection.stopped
        
        let fromIndex = currentPage
        var toIndex = -1
        if(self.pendingIndex >= 0) {
            toIndex = pendingIndex
            if(toIndex < fromIndex) {
                direction = NavigationDirection.left
            } else if(toIndex > fromIndex) {
                direction = NavigationDirection.right
            }
        }
        var percentage: CGFloat = 1
        if(toIndex != fromIndex) {
            let offset = scrollView.contentOffset.x
            let bounds = scrollView.bounds.width
            percentage = (abs(offset - bounds) / bounds)
        }
        if(!stopAnimation && toIndex != -1) {
            selectPage(toIndex, fromIndex: fromIndex, progress: percentage, direction: direction)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if(!stopAnimation && self.pageController.scrollView?.isDecelerating == false) {
            self.selectPage(self.currentPage)
        }
    }
    
}
