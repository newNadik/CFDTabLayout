//
//  CFDTabLayout.swift
//  CFDTabLayout
//
//  Created by Nadiia Ivanova on 31/07/2021.
//

import UIKit


@objc public class CFDTabLayout: UIView {
    
    @IBOutlet weak var tabsCollectionView: UICollectionView!
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout! {
        didSet {
            collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }

    @IBOutlet weak var containerView: UIView!
    var pageController = CFDPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    var currentPage = 0
    var pendingIndex = 0
    var startOffset: CGFloat = 0
    var stopAnimation = false
    
    @IBInspectable open var indicatorHeight: CGFloat = 3
    @IBInspectable open var selectedColor: UIColor = .systemBlue
    @IBInspectable open var unselectedColor: UIColor = .secondaryLabel
    
    weak open var delegate: CFDTabLayoutProtocol? {
        didSet {
            reloadData()
        }
    }
    
    open func reloadData() {
        tabsCollectionView.reloadData()
        pageController.setViewControllers([viewControllerAt(index: currentPage)], direction: UIPageViewController.NavigationDirection.forward,
                                          animated: true, completion: nil)
    }
    
    //MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    deinit { }
    
    func xibSetup() {
        let view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let nib = UINib(nibName: "CFDTabLayout", bundle: Bundle.module)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        tabsCollectionView.register(UINib(nibName: "CFDTabCollectionViewCell", bundle: Bundle.module), forCellWithReuseIdentifier: "CFDTabCollectionViewCell")
        if let parentController = parentViewController {
            pageController.dataSource = self
            pageController.delegate = self
            pageController.scrollView?.delegate = self
//            pageController.setViewControllers([viewControllerAt(index: currentPage)], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
                        
            parentController.addChild(pageController)
            pageController.view.frame = containerView.bounds
            containerView.addSubview(pageController.view)
            pageController.didMove(toParent: parentController)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.selectPage(self.currentPage)
        }
    }
    
    func viewControllerAt(index: Int) -> UIViewController {
        let vc = delegate?.tabLayout(self, viewControllerAt: index) ?? UIViewController()
        vc.view.tag = index
        return vc
    }
    
    func titleForTabAt(index: Int) -> String {
        return delegate?.tabLayout(self, titleAt: index) ?? ""
    }
    
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
            self.selectPage(currentPage)
        }
    }
    
}

extension CFDTabLayout: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (delegate?.numberOfPages(in: self) ?? 0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CFDTabCollectionViewCell", for: indexPath) as! CFDTabCollectionViewCell
        cell.tabsCollectionHeight.constant = collectionView.bounds.height
        cell.indicatorHeight.constant = indicatorHeight
        cell.setColors(selectedColor: selectedColor, unselectedColor: unselectedColor)
        cell.setTitle(titleForTabAt(index: indexPath.item))
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        moveToPage(index: indexPath.item)
    }
    
}

enum NavigationDirection {
    case stopped
    case right
    case left
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
        /* //Total scroll progress
        let offset = scrollView.contentOffset.x
        let bounds = scrollView.bounds.width
        let page = CGFloat(self.currentPage)
        let count = CGFloat(numberOfPages)
        let percentage = (offset - bounds + page * bounds) / (count * bounds - bounds)
        
        print("PAGE SCROLL \(percentage)") */
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if(self.pageController.scrollView?.isDecelerating == false) {
            self.selectPage(self.currentPage)
        }
    }
    
    func selectPage(_ toIndex: Int, fromIndex: Int = -1, progress: CGFloat = 1, direction: NavigationDirection = .stopped) {
        for i in 0..<(delegate?.numberOfPages(in: self) ?? 0) {
            if let toCell = tabsCollectionView.cellForItem(at: IndexPath(item: i, section: 0)) as? CFDTabCollectionViewCell {
                if(i == toIndex) {
                    toCell.moveTo(progress: progress, direction: direction)
                } else if(i == fromIndex) {
                    toCell.moveFrom(progress: progress, direction: direction)
                } else {
                    toCell.moveTo(progress: 0, direction: .stopped)
                }
            }
        }
    }
    
    func moveToPage(index: Int) {
        if index < (delegate?.numberOfPages(in: self) ?? 0) {
            if index > currentPage {
                let vc = viewControllerAt(index: index)
                self.stopAnimation = (index - currentPage) > 1
                self.pageController.setViewControllers([vc], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: { (complete) -> Void in
                    self.currentPage = index
                    self.selectPage(index)
                    self.stopAnimation = false
                })
            } else if index < currentPage {
                let vc = viewControllerAt(index: index)
                self.stopAnimation = (currentPage - index) > 1
                self.pageController.setViewControllers([vc], direction: UIPageViewController.NavigationDirection.reverse, animated: true, completion: { (complete) -> Void in
                    self.currentPage = index
                    self.selectPage(index)
                    self.stopAnimation = false
                })
            }
        }
    }
    
}
