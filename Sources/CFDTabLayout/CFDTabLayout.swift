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
        tabsCollectionView.scrollToItem(at: IndexPath(item: toIndex, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    func moveToPage(index: Int) {
        if index < (delegate?.numberOfPages(in: self) ?? 0) {
            if index > currentPage {
                let vc = viewControllerAt(index: index)
                self.stopAnimation = true // (index - currentPage) > 1
                self.pageController.setViewControllers([vc], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: { (complete) -> Void in
                    self.currentPage = index
                    self.selectPage(index)
                    self.stopAnimation = false
                })
            } else if index < currentPage {
                let vc = viewControllerAt(index: index)
                self.stopAnimation = true // (currentPage - index) > 1
                self.pageController.setViewControllers([vc], direction: UIPageViewController.NavigationDirection.reverse, animated: true, completion:
                                                        { (complete) -> Void in
                    self.currentPage = index
                    self.selectPage(index)
                    self.stopAnimation = false
                })
            }
        }
    }
    
}
