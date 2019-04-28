//
//  ParallaxHeader.swift
//  ParallaxHeader
//
//  Created by Roman Sorochak on 6/22/17.
//  Copyright © 2017 MagicLab. All rights reserved.
//

import UIKit
import ObjectiveC.runtime


public typealias ParallaxHeaderHandlerBlock = (_ parallaxHeader: ParallaxHeader)->Void


private let parallaxHeaderKVOContext = UnsafeMutableRawPointer.allocate(
    byteCount: 4,
    alignment: 1
)

class ParallaxView: UIView {
    
    fileprivate weak var parent: ParallaxHeader!
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard let scrollView = self.superview as? UIScrollView else {
            return
        }
        scrollView.removeObserver(
            self.parent,
            forKeyPath: NSStringFromSelector(
                #selector(getter: scrollView.contentOffset)
            ),
            context: parallaxHeaderKVOContext
        )
    }
    
    override func didMoveToSuperview() {
        guard let scrollView = self.superview as? UIScrollView else {
            return
        }
        scrollView.addObserver(
            self.parent,
            forKeyPath: NSStringFromSelector(
                #selector(getter: scrollView.contentOffset)
            ),
            options: NSKeyValueObservingOptions.new,
            context: parallaxHeaderKVOContext
        )
    }
}


/**
 The ParallaxHeader class represents a parallax header for UIScrollView.
 */
public class ParallaxHeader: NSObject {
    
    //MARK: properties
    
    /**
     Block to handle parallax header scrolling.
     */
    public var parallaxHeaderDidScrollHandler: ParallaxHeaderHandlerBlock?
    
    private weak var _scrollView: UIScrollView?
    var scrollView: UIScrollView! {
        get {
            return _scrollView
        }
        set(scrollView) {
            guard let scrollView = scrollView,
                scrollView != _scrollView else {
                    return
            }
            _scrollView = scrollView
            
            adjustScrollViewTopInset(
                top: scrollView.contentInset.top + height
            )
            scrollView.addSubview(contentView)
            
            layoutContentView()
        }
    }
    
    /**
     The content view on top of the UIScrollView's content.
     */
    private var _contentView: UIView?
    var contentView: UIView {
        get {
            if let contentView = _contentView {
                return contentView
            }
            let contentView = ParallaxView()
            contentView.parent = self
            contentView.clipsToBounds = true
            
            _contentView = contentView
            
            return contentView
        }
    }
    
    /**
     The header's view.
     */
    private var _view: UIView?
    public var view: UIView {
        get {
            return _view!
        }
        set(view) {
            guard _view != view else {
                return
            }
            _view = view
            updateConstraints()
        }
    }
    
    /**
     The parallax header behavior mode. By default is fill mode.
     */
    private var _mode: ParallaxHeaderMode = .fill
    public var mode: ParallaxHeaderMode {
        get {
            return _mode
        }
        set(mode) {
            guard _mode != mode else {
                return
            }
            _mode = mode
            updateConstraints()
        }
    }
    
    /**
     The header's default height. 0 0 by default.
     */
    private var _height: CGFloat = 0
    public var height: CGFloat {
        get {
            return _height
        }
        set(height) {
            guard _height != height,
                let scrollView = scrollView else {
                    return
            }
            adjustScrollViewTopInset(
                top: scrollView.contentInset.top - _height + height
            )
            
            _height = height
            
            updateConstraints()
            layoutContentView()
        }
    }
    
    /**
     The header's minimum height while scrolling up. 0 by default.
     */
    public var minimumHeight: CGFloat = 0 {
        didSet {
            layoutContentView()
        }
    }
    
    /**
     The parallax header progress value.
     */
    private var _progress: CGFloat = 0
    public var progress: CGFloat {
        get {
            return _progress
        }
        set(progress) {
            guard _progress != progress else {
                return
            }
            _progress = progress
            
            parallaxHeaderDidScrollHandler?(self)
        }
    }
    
    
    //MARK: constraints
    
    private func updateConstraints(update: Bool = false) {
        if !update {
            view.removeFromSuperview()
            contentView.addSubview(view)
            
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        switch mode {
        case .fill:
            setFillModeConstraints()
        case .top:
            setTopModeConstraints()
        case .topFill:
            setTopFillModeConstraints()
        case .center:
            setCenterModeConstraints()
        case .centerFill:
            setCenterFillModeConstraints()
        case .bottom:
            setBottomModeConstraints()
        case .bottomFill:
            setBottomFillModeConstraints()
        }
    }
    
    private func setFillModeConstraints() {
        let binding = [
            "v" : view
        ]
        
        contentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[v]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: binding
            )
        )
        contentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[v]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: binding
            )
        )
    }
    
    private func setTopModeConstraints() {
        let binding = [
            "v" : view
        ]
        let metrics = [
            "height" : height
        ]
        contentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[v]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: binding
            )
        )
        contentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[v(==height)]",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: metrics,
                views: binding
            )
        )
    }
    
    private func setTopFillModeConstraints() {
        let binding = [
            "v" : view
        ]
        let metrics = [
            "highPriority" : UILayoutPriority.defaultHigh,
            "height" : height
            ] as [String : Any]
        contentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[v]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: binding
            )
        )
        contentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[v(>=height)]-0.0@highPriority-|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: metrics,
                views: binding
            )
        )
    }
    
    private func setCenterModeConstraints() {
        let binding = [
            "v" : view
        ]
        contentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[v]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: binding
            )
        )
        
        contentView.addConstraint(
            NSLayoutConstraint(
                item: view,
                attribute: NSLayoutConstraint.Attribute.centerY,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: contentView,
                attribute: NSLayoutConstraint.Attribute.centerY,
                multiplier: 1,
                constant: 0
            )
        )
        contentView.addConstraint(
            NSLayoutConstraint(
                item: view,
                attribute: NSLayoutConstraint.Attribute.centerX,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: contentView,
                attribute: NSLayoutConstraint.Attribute.centerX,
                multiplier: 1,
                constant: 0
            )
        )
    }
    
    private func setCenterFillModeConstraints() {
        let binding = [
            "v" : view
        ]
        let metrics = [
            "highPriority" : UILayoutPriority.defaultHigh,
            "height" : height
            ] as [String : Any]
        contentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[v]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: binding
            )
        )
        contentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0@highPriority-[v(>=height)]-0@highPriority-|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: metrics,
                views: binding
            )
        )
        
        contentView.addConstraint(
            NSLayoutConstraint(
                item: view,
                attribute: NSLayoutConstraint.Attribute.centerY,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: contentView,
                attribute: NSLayoutConstraint.Attribute.centerX,
                multiplier: 1,
                constant: 0
            )
        )
        contentView.addConstraint(
            NSLayoutConstraint(
                item: view,
                attribute: NSLayoutConstraint.Attribute.centerX,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: contentView,
                attribute: NSLayoutConstraint.Attribute.centerX,
                multiplier: 1,
                constant: 0
            )
        )
    }
    
    private func setBottomModeConstraints() {
        let binding = [
            "v" : view
        ]
        let metrics = [
            "height" : height
        ]
        contentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[v]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: binding
            )
        )
        contentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:[v(==height)]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: metrics,
                views: binding
            )
        )
    }
    
    private func setBottomFillModeConstraints() {
        let binding = [
            "v" : view
        ]
        let metrics = [
            "highPriority" : UILayoutPriority.defaultHigh,
            "height" : height
            ] as [String : Any]
        contentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[v]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: binding
            )
        )
        contentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0.0@highPriority-[v(>=height)]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: metrics,
                views: binding
            )
        )
    }
    
    
    //MARK: private
    
    private func layoutContentView() {
        guard let scrollView = scrollView else {
            return
        }
        let minimumHeight = min(self.minimumHeight, self.height)
        let relativeYOffset = scrollView.contentOffset.y + scrollView.contentInset.top - height
        let relativeHeight = -relativeYOffset
        
        let frame = CGRect(
            x: 0,
            y: relativeYOffset,
            width: scrollView.frame.size.width,
            height: max(relativeHeight, minimumHeight)
        )
        contentView.frame = frame
        
        let div = self.height - self.minimumHeight
        progress = (self.contentView.frame.size.height - self.minimumHeight) / div
    }
    
    private func adjustScrollViewTopInset(top: CGFloat) {
        guard let scrollView = scrollView else {
            return
        }
        var inset = scrollView.contentInset
        
        //Adjust content offset
        var offset = scrollView.contentOffset
        offset.y += inset.top - top
        scrollView.contentOffset = offset
        
        //Adjust content inset
        inset.top = top
        scrollView.contentInset = inset
    }
    
    
    //MARK: KVO
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == parallaxHeaderKVOContext,
            let scrollView = scrollView else {
                super.observeValue(
                    forKeyPath: keyPath,
                    of: object,
                    change: change,
                    context: context
                )
                return
        }
        if keyPath == NSStringFromSelector(#selector(getter: scrollView.contentOffset)) {
            layoutContentView()
        }
    }
}
