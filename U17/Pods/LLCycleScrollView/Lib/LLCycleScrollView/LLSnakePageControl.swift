//
//  LLSnakePageControl.swift
//  LL 使用备注
//  https://github.com/popwarsweet/PageControls
//
//  Created by Kyle Zaragoza on 8/5/16.
//  Copyright © 2016 Kyle Zaragoza. All rights reserved.
//

import UIKit

open class LLSnakePageControl: UIView {
    
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
    open var indicatorPadding: CGFloat = 10 {
        didSet {
            layoutInactivePageIndicators(inactiveLayers)
        }
    }
    open var indicatorRadius: CGFloat = 5 {
        didSet {
            layoutInactivePageIndicators(inactiveLayers)
        }
    }
    
    fileprivate var indicatorDiameter: CGFloat {
        return indicatorRadius * 2
    }
    fileprivate var inactiveLayers = [CALayer]()
    fileprivate lazy var activeLayer: CALayer = { [unowned self] in
        let layer = CALayer()
        layer.frame = CGRect(origin: CGPoint.zero,
                             size: CGSize(width: self.indicatorDiameter, height: self.indicatorDiameter))
        layer.backgroundColor = self.activeTint.cgColor
        layer.cornerRadius = self.indicatorRadius
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
        indicatorPadding = 8
        indicatorRadius = 4
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
        let denormalizedProgress = progress * (indicatorDiameter + indicatorPadding)
        let distanceFromPage = abs(round(progress) - progress)
        var newFrame = activeLayer.frame
        let widthMultiplier = (1 + distanceFromPage*2)
        newFrame.origin.x = denormalizedProgress
        newFrame.size.width = newFrame.height * widthMultiplier
        activeLayer.frame = newFrame
    }
    
    fileprivate func layoutInactivePageIndicators(_ layers: [CALayer]) {
        let layerDiameter = indicatorRadius * 2
        var layerFrame = CGRect(x: 0, y: 0, width: layerDiameter, height: layerDiameter)
        layers.forEach() { layer in
            layer.cornerRadius = self.indicatorRadius
            layer.frame = layerFrame
            layerFrame.origin.x += layerDiameter + indicatorPadding
        }
        // 布局
        let oldFrame = self.frame
        let width = CGFloat(inactiveLayers.count) * indicatorDiameter + CGFloat(inactiveLayers.count - 1) * indicatorPadding
        self.frame = CGRect.init(x: UIScreen.main.bounds.width / 2 - width / 2, y: oldFrame.origin.y, width: width, height: oldFrame.size.height)
    }
    
    override open var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSize.zero)
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: CGFloat(inactiveLayers.count) * indicatorDiameter + CGFloat(inactiveLayers.count - 1) * indicatorPadding,
                      height: indicatorDiameter)
    }
}
