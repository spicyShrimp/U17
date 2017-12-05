//
//  EmptyDataSetView+Extension.swift
//  EmptyDataSet-Swift
//
//  Created by YZF on 3/7/17.
//  Copyright © 2017年 Xiaoye. All rights reserved.
//

import Foundation
import UIKit

extension EmptyDataSetView {
    
    //MARK: - Data Source 
    @discardableResult
    public func titleLabelString(_ attributedString: NSAttributedString?) -> Self {
        titleLabel.attributedText = attributedString
        return self
    }
    
    @discardableResult
    public func detailLabelString(_ attributedString: NSAttributedString?) -> Self {
        detailLabel.attributedText = attributedString
        return self
    }
    
    @discardableResult
    public func image(_ image: UIImage?) -> Self {
        imageView.image = image
        return self
    }
    
    @discardableResult
    public func imageAnimation(_ imageAnimation: CAAnimation?) -> Self {
        if let ani = imageAnimation {
            imageView.layer.add(ani, forKey: nil)
        }
        return self
    }
    
    @discardableResult
    public func imageTintColor(_ imageTintColor: UIColor?) -> Self {
        imageView.tintColor = imageTintColor
        return self
    }
    
    @discardableResult
    public func buttonTitle(_ buttonTitle: NSAttributedString?, for state: UIControlState) -> Self {
        button.setAttributedTitle(buttonTitle, for: state)
        return self
    }
    
    @discardableResult
    public func buttonImage(_ buttonImage: UIImage?, for state: UIControlState) -> Self {
        button.setImage(buttonImage, for: state)
        return self
    }
    
    @discardableResult
    public func buttonBackgroundImage(_ buttonBackgroundImage: UIImage?, for state: UIControlState) -> Self {
        button.setBackgroundImage(buttonBackgroundImage, for: state)
        return self
    }
    
    @discardableResult
    public func dataSetBackgroundColor(_ backgroundColor: UIColor?) -> Self {
        self.backgroundColor = backgroundColor
        return self
    }
    
    @discardableResult
    public func customView(_ customView: UIView?) -> Self {
        self.customView = customView
        return self
    }
    
    @discardableResult
    public func verticalOffset(_ offset: CGFloat) -> Self {
        verticalOffset = offset
        return self
    }
    
    @discardableResult
    public func verticalSpace(_ space: CGFloat) -> Self {
        verticalSpace = space
        return self
    }
    
    //MARK: - Delegate & Events
    
    @discardableResult
    public func shouldFadeIn(_ bool: Bool) -> Self {
        fadeInOnDisplay = bool
        return self
    }
    
    @discardableResult
    public func shouldDisplay(_ bool: Bool, view: UIScrollView) -> Self {
        if !(bool && view.itemsCount == 0) {
            prepareForReuse()
            removeFromSuperview()
        }
        return self
    }
    
    @discardableResult
    public func isTouchAllowed(_ bool: Bool) -> Self {
        isUserInteractionEnabled = bool
        return self
    }
    
    @discardableResult
    public func isScrollAllowed(_ bool: Bool) -> Self {
        if let superview = superview as? UIScrollView {
            superview.isScrollEnabled = bool
        }
        return self
    }
    
    @discardableResult
    public func isImageViewAnimateAllowed(_ bool: Bool) -> Self {
        if !bool {
            imageView.layer.removeAllAnimations()
        }
        return self
    }
    
    @discardableResult
    public func didTapContentView(_ closure: @escaping () -> (Void)) -> Self {
        didTapContentViewHandle = closure
        return self
    }
    
    @discardableResult
    public func didTapDataButton(_ closure: @escaping () -> (Void)) -> Self {
        didTapDataButtonHandle = closure
        return self
    }
    
}
