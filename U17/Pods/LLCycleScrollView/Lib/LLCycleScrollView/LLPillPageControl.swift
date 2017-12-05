//
//  LLPillPageControl.swift
//  LL 使用备注
//  https://github.com/popwarsweet/PageControls
//
//  Created by Kyle Zaragoza on 8/8/16.
//  Copyright © 2016 Kyle Zaragoza. All rights reserved.
//

import UIKit

open class LLPillPageControl: UIView {
    
    // MARK: - PageControl
    
    open var pageCount: Int = 0 {
        didSet {
            updateNumberOfPages(pageCount)
        }
    }
    open var progress: CGFloat = 0 {
        didSet {
            layoutActivePageIndicator(progress)
        }
    }
    open var currentPage: Int {
        return Int(round(progress))
    }
    
    
    // MARK: - Appearance
    
    open var pillSize: CGSize = CGSize(width: 20, height: 2.5) {
        didSet {
            
        }
    }
    open var activeTint: UIColor = UIColor.white {
        didSet {
            activeLayer.backgroundColor = activeTint.cgColor
        }
    }
    open var inactiveTint: UIColor = UIColor(white: 1, alpha: 0.3) {
        didSet {
            inactiveLayers.forEach() { $0.backgroundColor = inactiveTint.cgColor }
        }
    }
    open var indicatorPadding: CGFloat = 7 {
        didSet {
            layoutInactivePageIndicators(inactiveLayers)
        }
    }
    
    fileprivate var inactiveLayers = [CALayer]()
    
    fileprivate lazy var activeLayer: CALayer = { [unowned self] in
        let layer = CALayer()
        layer.frame = CGRect(origin: CGPoint.zero,
                             size: CGSize(width: self.pillSize.width, height: self.pillSize.height))
        layer.backgroundColor = self.activeTint.cgColor
        layer.cornerRadius = self.pillSize.height/2
        layer.actions = [
            "bounds": NSNull(),
            "frame": NSNull(),
            "position": NSNull()]
        return layer
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        pageCount = 0
        progress = 0
        indicatorPadding = 7
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - State Update
    
    fileprivate func updateNumberOfPages(_ count: Int) {
        // no need to update
        guard count != inactiveLayers.count else { return }
        // reset current layout
        inactiveLayers.forEach() { $0.removeFromSuperlayer() }
        inactiveLayers = [CALayer]()
        // add layers for new page count
        inactiveLayers = stride(from: 0, to:count, by:1).map() { _ in
            let layer = CALayer()
            layer.backgroundColor = self.inactiveTint.cgColor
            self.layer.addSublayer(layer)
            return layer
        }
        layoutInactivePageIndicators(inactiveLayers)
        // ensure active page indicator is on top
        self.layer.addSublayer(activeLayer)
        layoutActivePageIndicator(progress)
        self.invalidateIntrinsicContentSize()
    }
    
    
    // MARK: - Layout
    
    fileprivate func layoutActivePageIndicator(_ progress: CGFloat) {
        // ignore if progress is outside of page indicators' bounds
        guard progress >= 0 && progress <= CGFloat(pageCount - 1) else { return }
        let denormalizedProgress = progress * (pillSize.width + indicatorPadding)
        activeLayer.frame.origin.x = denormalizedProgress
    }
    
    fileprivate func layoutInactivePageIndicators(_ layers: [CALayer]) {
        var layerFrame = CGRect(origin: CGPoint.zero, size: pillSize)
        layers.forEach() { layer in
            layer.cornerRadius = layerFrame.size.height / 2
            layer.frame = layerFrame
            layerFrame.origin.x += layerFrame.width + indicatorPadding
        }
        // 布局
        let oldFrame = self.frame
        let width = CGFloat(inactiveLayers.count) * pillSize.width + CGFloat(inactiveLayers.count - 1) * indicatorPadding
        self.frame = CGRect.init(x: UIScreen.main.bounds.width / 2 - width / 2, y: oldFrame.origin.y, width: width, height: oldFrame.size.height)
    }
    
    override open var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSize.zero)
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: CGFloat(inactiveLayers.count) * pillSize.width + CGFloat(inactiveLayers.count - 1) * indicatorPadding,
                      height: pillSize.height)
    }
}

