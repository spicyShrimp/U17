//
//  EmptyDataSet.swift
//  EmptyDataSet-Swift
//
//  Created by YZF on 28/6/17.
//  Copyright © 2017年 Xiaoye. All rights reserved.
//

import Foundation
import UIKit

class WeakObjectContainer: NSObject {
    weak var weakObject: AnyObject?
    
    init(with weakObject: Any?) {
        super.init()
        self.weakObject = weakObject as AnyObject?
    }
}

private var kEmptyDataSetSource =           "emptyDataSetSource"
private var kEmptyDataSetDelegate =         "emptyDataSetDelegate"
private var kEmptyDataSetView =             "emptyDataSetView"
private var kConfigureEmptyDataSetView =    "configureEmptyDataSetView"

extension UIScrollView: UIGestureRecognizerDelegate {
    
    private var configureEmptyDataSetView: ((EmptyDataSetView) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &kConfigureEmptyDataSetView) as? (EmptyDataSetView) -> Void
        }
        set {
            objc_setAssociatedObject(self, &kConfigureEmptyDataSetView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            UIScrollView.swizzleReloadData
            if self is UITableView {
                UIScrollView.swizzleEndUpdates
            }
        }
    }
    
    //MARK: - Public Property
    public var emptyDataSetSource: EmptyDataSetSource? {
        get {
            let container = objc_getAssociatedObject(self, &kEmptyDataSetSource) as? WeakObjectContainer
            return container?.weakObject as? EmptyDataSetSource
        }
        set {
            if newValue == nil {
                self.invalidate()
            }

            objc_setAssociatedObject(self, &kEmptyDataSetSource, WeakObjectContainer(with: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            UIScrollView.swizzleReloadData
            if self is UITableView {
                UIScrollView.swizzleEndUpdates
            }
        }
    }
    
    public var emptyDataSetDelegate: EmptyDataSetDelegate? {
        get {
            let container = objc_getAssociatedObject(self, &kEmptyDataSetDelegate) as? WeakObjectContainer
            return container?.weakObject as? EmptyDataSetDelegate
        }
        set {
            if newValue == nil {
                self.invalidate()
            }
            objc_setAssociatedObject(self, &kEmptyDataSetDelegate, WeakObjectContainer(with: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var isEmptyDataSetVisible: Bool {
        if let view = objc_getAssociatedObject(self, &kEmptyDataSetView) as? EmptyDataSetView {
            return !view.isHidden
        }
        return false
    }
    
    //MARK: - privateProperty
    public func emptyDataSetView(_ closure: @escaping (EmptyDataSetView) -> Void) {
        configureEmptyDataSetView = closure
    }
    
    private var emptyDataSetView: EmptyDataSetView? {
        get {
            if let view = objc_getAssociatedObject(self, &kEmptyDataSetView) as? EmptyDataSetView {
                return view
            } else {
                let view = EmptyDataSetView.init(frame: frame)
                view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                view.isHidden = true
                let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(didTapContentView(_:)))
                tapGesture.delegate = self
                view.addGestureRecognizer(tapGesture)
                view.button.addTarget(self, action: #selector(didTapDataButton(_:)), for: .touchUpInside)

                objc_setAssociatedObject(self, &kEmptyDataSetView, view, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                return view
            }
        }
        set {
            objc_setAssociatedObject(self, &kEmptyDataSetView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    internal var itemsCount: Int {
        var items = 0
        
        // UITableView support
        if let tableView = self as? UITableView {
            var sections = 1
            
            if let dataSource = tableView.dataSource {
                if dataSource.responds(to: #selector(UITableViewDataSource.numberOfSections(in:))) {
                    sections = dataSource.numberOfSections!(in: tableView)
                }
                if dataSource.responds(to: #selector(UITableViewDataSource.tableView(_:numberOfRowsInSection:))) {
                    for i in 0 ..< sections {
                        items += dataSource.tableView(tableView, numberOfRowsInSection: i)
                    }
                }
            }
        } else if let collectionView = self as? UICollectionView {
            var sections = 1
            
            if let dataSource = collectionView.dataSource {
                if dataSource.responds(to: #selector(UICollectionViewDataSource.numberOfSections(in:))) {
                    sections = dataSource.numberOfSections!(in: collectionView)
                }
                if dataSource.responds(to: #selector(UICollectionViewDataSource.collectionView(_:numberOfItemsInSection:))) {
                    for i in 0 ..< sections {
                        items += dataSource.collectionView(collectionView, numberOfItemsInSection: i)
                    }
                }
            }
        }
        
        return items
    }
    
    //MARK: - Data Source Getters
    private var titleLabelString: NSAttributedString? {
        return emptyDataSetSource?.title(forEmptyDataSet: self)
    }
    
    private var detailLabelString: NSAttributedString? {
        return emptyDataSetSource?.description(forEmptyDataSet: self)
    }
    
    private var image: UIImage? {
        return emptyDataSetSource?.image(forEmptyDataSet: self)
    }
    
    private var imageAnimation: CAAnimation? {
        return emptyDataSetSource?.imageAnimation(forEmptyDataSet: self)
    }
    
    private var imageTintColor: UIColor? {
        return emptyDataSetSource?.imagetintColor(forEmptyDataSet: self)
    }
    
    private func buttonTitle(for state: UIControl.State) -> NSAttributedString? {
        return emptyDataSetSource?.buttonTitle(forEmptyDataSet: self, for: state)
    }
    
    private func buttonImage(for state: UIControl.State) -> UIImage? {
        return emptyDataSetSource?.buttonImage(forEmptyDataSet: self, for: state)
    }
    
    private func buttonBackgroundImage(for state: UIControl.State) -> UIImage? {
        return emptyDataSetSource?.buttonBackgroundImage(forEmptyDataSet: self, for: state)
    }
    
    private var dataSetBackgroundColor: UIColor? {
        return emptyDataSetSource?.backgroundColor(forEmptyDataSet: self)
    }
    
    private var customView: UIView? {
        return emptyDataSetSource?.customView(forEmptyDataSet: self)
    }
    
    private var verticalOffset: CGFloat {
        return emptyDataSetSource?.verticalOffset(forEmptyDataSet: self) ?? 0.0
    }
    
    private var verticalSpace: CGFloat {
        return emptyDataSetSource?.spaceHeight(forEmptyDataSet: self) ?? 0.0
    }
    
    //MARK: - Delegate Getters & Events (Private)
    
    private var shouldFadeIn: Bool {
        return emptyDataSetDelegate?.emptyDataSetShouldFadeIn(self) ?? true
    }
    
    private var shouldDisplay: Bool {
        return emptyDataSetDelegate?.emptyDataSetShouldDisplay(self) ?? true
    }
    
    private var shouldBeForcedToDisplay: Bool {
        return emptyDataSetDelegate?.emptyDataSetShouldBeForcedToDisplay(self) ?? false
    }
    
    private var isTouchAllowed: Bool {
        return emptyDataSetDelegate?.emptyDataSetShouldAllowTouch(self) ?? true
    }
    
    private var isScrollAllowed: Bool {
        return emptyDataSetDelegate?.emptyDataSetShouldAllowScroll(self) ?? false
    }
    
    private var isImageViewAnimateAllowed: Bool {
        return emptyDataSetDelegate?.emptyDataSetShouldAnimateImageView(self) ?? false
    }
    
    private func willAppear() {
        emptyDataSetDelegate?.emptyDataSetWillAppear(self)
        emptyDataSetView?.willAppearHandle?()
    }
    
    private func didAppear() {
        emptyDataSetDelegate?.emptyDataSetDidAppear(self)
        emptyDataSetView?.didAppearHandle?()
    }
    
    private func willDisappear() {
        emptyDataSetDelegate?.emptyDataSetWillDisappear(self)
        emptyDataSetView?.willDisappearHandle?()
    }
    
    private func didDisappear() {
        emptyDataSetDelegate?.emptyDataSetDidDisappear(self)
        emptyDataSetView?.didDisappearHandle?()
    }
    
    @objc private func didTapContentView(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        emptyDataSetDelegate?.emptyDataSet(self, didTapView: view)
        emptyDataSetView?.didTapContentViewHandle?()
    }
    
    @objc private func didTapDataButton(_ sender: UIButton) {
        emptyDataSetDelegate?.emptyDataSet(self, didTapButton: sender)
        emptyDataSetView?.didTapDataButtonHandle?()
    }
    
    //MARK: - Reload APIs (Public)
    public func reloadEmptyDataSet() {
        guard (emptyDataSetSource != nil || configureEmptyDataSetView != nil) else {
            return
        }
        
        if (shouldDisplay && itemsCount == 0) || shouldBeForcedToDisplay {
            // Notifies that the empty dataset view will appear
            willAppear()
            
            if let view = emptyDataSetView {
                
                // Configure empty dataset fade in display
                view.fadeInOnDisplay = shouldFadeIn
                
                if view.superview == nil {
                    // Send the view all the way to the back, in case a header and/or footer is present, as well as for sectionHeaders or any other content
                    if (self is UITableView) || (self is UICollectionView) || (subviews.count > 1) {
                        insertSubview(view, at: 0)
                    } else {
                        addSubview(view)
                    }
                }
                
                // Removing view resetting the view and its constraints it very important to guarantee a good state
                // If a non-nil custom view is available, let's configure it instead
                view.prepareForReuse()
                
                if let customView = self.customView {
                    view.customView = customView
                } else {
                    // Get the data from the data source
                    
                    let renderingMode: UIImage.RenderingMode = imageTintColor != nil ? .alwaysTemplate : .alwaysOriginal
                    
                    view.verticalSpace = verticalSpace
                    
                    // Configure Image
                    if let image = image {
                        view.imageView.image = image.withRenderingMode(renderingMode)
                        if let imageTintColor = imageTintColor {
                            view.imageView.tintColor = imageTintColor
                        }
                    }
                    
                    // Configure title label
                    if let titleLabelString = titleLabelString {
                        view.titleLabel.attributedText = titleLabelString
                    }
                    
                    // Configure detail label
                    if let detailLabelString = detailLabelString {
                        view.detailLabel.attributedText = detailLabelString
                    }
                    
                    // Configure button
                    if let buttonImage = buttonImage(for: .normal) {
                        view.button.setImage(buttonImage, for: .normal)
                        view.button.setImage(self.buttonImage(for: .highlighted), for: .highlighted)
                    } else if let buttonTitle = buttonTitle(for: .normal) {
                        view.button.setAttributedTitle(buttonTitle, for: .normal)
                        view.button.setAttributedTitle(self.buttonTitle(for: .highlighted), for: .highlighted)
                        view.button.setBackgroundImage(self.buttonBackgroundImage(for: .normal), for: .normal)
                        view.button.setBackgroundImage(self.buttonBackgroundImage(for: .highlighted), for: .highlighted)
                    }
                }
                
                // Configure offset
                view.verticalOffset = verticalOffset
                
                // Configure the empty dataset view
                view.backgroundColor = dataSetBackgroundColor
                view.isHidden = false
                view.clipsToBounds = true
                
                // Configure empty dataset userInteraction permission
                view.isUserInteractionEnabled = isTouchAllowed
                
                // Configure scroll permission
                self.isScrollEnabled = isScrollAllowed
                
                // Configure image view animation
                if self.isImageViewAnimateAllowed {
                    if let animation = imageAnimation {
                        view.imageView.layer.add(animation, forKey: nil)
                    }
                } else {
                    view.imageView.layer.removeAllAnimations()
                }
                
                if let config = configureEmptyDataSetView {
                    config(view)
                }
                
                view.setupConstraints()
                view.layoutIfNeeded()
            }
            
            // Notifies that the empty dataset view did appear
            didAppear()
        } else if isEmptyDataSetVisible {
            invalidate()
        }
    }
    
    private func invalidate() {
        willDisappear()
        if let view = emptyDataSetView {
            view.prepareForReuse()
            view.isHidden = true
//            view.removeFromSuperview()
//            emptyDataSetView = nil
        }
        self.isScrollEnabled = true
        didDisappear()
    }
    
    
    //MARK: - Method Swizzling
    @objc private func tableViewSwizzledReloadData() {
        tableViewSwizzledReloadData()
        reloadEmptyDataSet()
    }
    
    @objc private func tableViewSwizzledEndUpdates() {
        tableViewSwizzledEndUpdates()
        reloadEmptyDataSet()
    }
    
    @objc private func collectionViewSwizzledReloadData() {
        collectionViewSwizzledReloadData()
        reloadEmptyDataSet()
    }
    
    private class func swizzleMethod(for aClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
        let originalMethod = class_getInstanceMethod(aClass, originalSelector)
        let swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector)
        
        let didAddMethod = class_addMethod(aClass, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        
        if didAddMethod {
            class_replaceMethod(aClass, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
    
    private static let swizzleReloadData: () = {
        let tableViewOriginalSelector = #selector(UITableView.reloadData)
        let tableViewSwizzledSelector = #selector(UIScrollView.tableViewSwizzledReloadData)
        
        swizzleMethod(for: UITableView.self, originalSelector: tableViewOriginalSelector, swizzledSelector: tableViewSwizzledSelector)
        
        let collectionViewOriginalSelector = #selector(UICollectionView.reloadData)
        let collectionViewSwizzledSelector = #selector(UIScrollView.collectionViewSwizzledReloadData)
        
        swizzleMethod(for: UICollectionView.self, originalSelector: collectionViewOriginalSelector, swizzledSelector: collectionViewSwizzledSelector)
    }()
    
    private static let swizzleEndUpdates: () = {
        let originalSelector = #selector(UITableView.endUpdates)
        let swizzledSelector = #selector(UIScrollView.tableViewSwizzledEndUpdates)
        
        swizzleMethod(for: UITableView.self, originalSelector: originalSelector, swizzledSelector: swizzledSelector)
    }()
}



