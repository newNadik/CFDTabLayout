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
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startOffset = scrollView.contentOffset.x
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var direction = NavigationDirection.stopped //scroll stopped
        
        let fromIndex = currentPage
        var toIndex = -1
        if startOffset < scrollView.contentOffset.x {
            direction = NavigationDirection.right
            if((fromIndex + 1) < (delegate?.numberOfPages(in: self) ?? 0)) {
                toIndex = fromIndex + 1
            }
        } else if startOffset > scrollView.contentOffset.x {
            direction = NavigationDirection.left
            if(fromIndex - 1 >= 0) {
                toIndex = fromIndex - 1
            }
        }
        let positionFromStartOfCurrentPage = abs(startOffset - scrollView.contentOffset.x)
        let percentage = (positionFromStartOfCurrentPage / pageController.view.frame.width)

        if(!stopAnimation && toIndex != -1) {
            selectPage(toIndex, fromIndex: fromIndex, progress: percentage, direction: direction)
        }
        //Total scroll progress
//        let offset = scrollView.contentOffset.x
//        let bounds = scrollView.bounds.width
//        let page = CGFloat(self.currentPage)
//        let count = CGFloat(delegate?.numberOfPages(in: self) ?? 0)
//        let percent = (offset - bounds + page * bounds) / (count * bounds - bounds)
//
//        print("PAGE SCROLL \(percent)")
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if(!stopAnimation && self.pageController.scrollView?.isDecelerating == false) {
            self.selectPage(self.currentPage)
        }
    }
    
    
}
