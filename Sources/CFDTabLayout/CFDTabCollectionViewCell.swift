//
//  CFDTabCollectionViewCell.swift
//  CFDTabLayout
//
//  Created by Nadiia Ivanova on 31/07/2021.
//

import UIKit

class CFDTabCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleSelectedLabel: UILabel!
    @IBOutlet weak var tabsCollectionHeight: NSLayoutConstraint!
    
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var indicatorHeight: NSLayoutConstraint!
    @IBOutlet weak var indicatorLeftAnchor: NSLayoutConstraint!
    @IBOutlet weak var indicatorRightAnchor: NSLayoutConstraint!
    @IBOutlet weak var indicatorWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        moveTo(progress: 0, direction: .stopped)
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
        titleSelectedLabel.text = title
    }
    
    func setColors(selectedColor: UIColor, unselectedColor: UIColor) {
        titleLabel.textColor = unselectedColor
        titleSelectedLabel.textColor = selectedColor
        
        indicatorView.backgroundColor = selectedColor
    }
    
    func moveTo(progress: CGFloat, direction: NavigationDirection) {
        titleLabel.alpha = 1 - progress
        titleSelectedLabel.alpha = progress
        indicatorWidth.constant = getWidth(percent: progress)
        
        indicatorLeftAnchor.isActive = direction == .right
        indicatorRightAnchor.isActive = direction == .left
    }
    
    func moveFrom(progress: CGFloat, direction: NavigationDirection) {
        titleLabel.alpha = progress
        titleSelectedLabel.alpha = 1 - progress
        indicatorWidth.constant = getWidth(percent: 1 - progress)
        indicatorLeftAnchor.isActive = direction == .left
        indicatorRightAnchor.isActive = direction == .right
    }
 
    func getWidth(percent: CGFloat) -> CGFloat {
        return self.bounds.size.width * percent
    }
    
}
