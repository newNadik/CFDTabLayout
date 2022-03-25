//
//  File.swift
//  
//
//  Created by Nadiia Ivanova on 05/08/2021.
//

import UIKit
import Foundation

extension CFDTabLayout: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (delegate?.numberOfPages(in: self) ?? 0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CFDTabCollectionViewCell", for: indexPath) as! CFDTabCollectionViewCell
        cell.fullWidth = self.fullWidth
        cell.setFont(self.tabFont)
        cell.tabsCollectionHeight.constant = collectionView.bounds.height
        cell.indicatorHeight.constant = indicatorHeight
        cell.setColors(selectedColor: selectedColor, unselectedColor: unselectedColor)
        cell.setTitle(titleForTabAt(index: indexPath.item))
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if(indexPath.item == self.currentPage) {
            (cell as? CFDTabCollectionViewCell)?.moveTo(progress: 1, direction: .right)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.pendingIndex = indexPath.item
        moveToPage(index: indexPath.item)
        delegate?.tabLayout?(self, didSelectTab: indexPath.item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(self.fullWidth) {
            let width = collectionView.bounds.width / CGFloat(max(self.delegate?.numberOfPages(in: self) ?? 0, 1))
            return CGSize(width: max(0, width), height: self.tabsCollectionView.bounds.height)
        }
        let title = titleForTabAt(index: indexPath.item)
        let titleSize = (title as NSString).size(withAttributes: [NSAttributedString.Key.font: self.tabFont])
        let width: CGFloat = 30 + titleSize.width
        return CGSize(width: width, height: collectionView.bounds.height)
    }
}
