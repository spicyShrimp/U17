//
//  EmptyDataSetView.swift
//  EmptyDataSet-Swift
//
//  Created by YZF on 28/6/17.
//  Copyright © 2017年 Xiaoye. All rights reserved.
//

import Foundation
import UIKit

public class EmptyDataSetView: UIView {
    
    internal lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor.clear
        contentView.isUserInteractionEnabled = true
        contentView.alpha = 0
        return contentView
    }()
    
    internal lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        imageView.accessibilityIdentifier = "empty set background image"
        self.contentView.addSubview(imageView)
        return imageView
    }()
    
    internal lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.backgroundColor = UIColor.clear
        
        titleLabel.font = UIFont.systemFont(ofSize: 27.0)
        titleLabel.textColor = UIColor(white: 0.6, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.accessibilityIdentifier = "empty set title"
        self.contentView.addSubview(titleLabel)
        return titleLabel
    }()
    
    internal lazy var detailLabel: UILabel = {
        let detailLabel = UILabel()
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.backgroundColor = UIColor.clear
        
        detailLabel.font = UIFont.systemFont(ofSize: 17.0)
        detailLabel.textColor = UIColor(white: 0.6, alpha: 1.0)
        detailLabel.textAlignment = .center
        detailLabel.lineBreakMode = .byWordWrapping
        detailLabel.numberOfLines = 0
        detailLabel.accessibilityIdentifier = "empty set detail label"
        self.contentView.addSubview(detailLabel)
        return detailLabel
    }()
    
    internal lazy var button: UIButton = {
        let button = UIButton.init(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clear
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.accessibilityIdentifier = "empty set button"
        
        self.contentView.addSubview(button)
        return button
    }()
    
    private var canShowImage: Bool {
        return imageView.image != nil
    }
    
    private var canShowTitle: Bool {
        if let attributedText = titleLabel.attributedText {
            return attributedText.length > 0
        }
        return false
    }
    
    private var canShowDetail: Bool {
        if let attributedText = detailLabel.attributedText {
            return attributedText.length > 0
        }
        return false
    }
    
    private var canShowButton: Bool {
        if let attributedTitle = button.attributedTitle(for: .normal) {
            return attributedTitle.length > 0
        } else if let _ = button.image(for: .normal) {
            return true
        }
        
        return false
    }
    
    
    internal var customView: UIView? {
        willSet {
            if let customView = customView {
                customView.removeFromSuperview()
            }
        }
        didSet {
            if let customView = customView {
                customView.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview(customView)
            }
        }
    }
    
    internal var fadeInOnDisplay = false
    internal var verticalOffset: CGFloat = 0
    internal var verticalSpace: CGFloat = 11
    
    internal var didTapContentViewHandle: (() -> Void)?
    internal var didTapDataButtonHandle: (() -> Void)?
    internal var willAppearHandle: (() -> Void)?
    internal var didAppearHandle: (() -> Void)?
    internal var willDisappearHandle: (() -> Void)?
    internal var didDisappearHandle: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func didMoveToSuperview() {
        if let superviewBounds = superview?.bounds {
            frame = CGRect(x: 0, y: 0, width: superviewBounds.width, height: superviewBounds.height)
        }
        if fadeInOnDisplay {
            UIView.animate(withDuration: 0.25) {
                self.contentView.alpha = 1
            }
        } else {
            contentView.alpha = 1
        }
    }
    
    // MARK: - Action Methods
    
    internal func removeAllConstraints() {
        removeConstraints(constraints)
        contentView.removeConstraints(contentView.constraints)
    }
    
    internal func prepareForReuse() {
        titleLabel.text = nil
        detailLabel.text = nil
        imageView.image = nil
        button.setImage(nil, for: .normal)
        button.setImage(nil, for: .highlighted)
        button.setAttributedTitle(nil, for: .normal)
        button.setAttributedTitle(nil, for: .highlighted)
        button.setBackgroundImage(nil, for: .normal)
        button.setBackgroundImage(nil, for: .highlighted)
        customView = nil
        
        removeAllConstraints()
    }
    
    
    // MARK: - Auto-Layout Configuration
    internal func setupConstraints() {
        
        // First, configure the content view constaints
        // The content view must alway be centered to its superview
        let centerXConstraint = NSLayoutConstraint(item: contentView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let centerYConstraint = NSLayoutConstraint(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        
        self.addConstraints([centerXConstraint, centerYConstraint])
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: [], metrics: nil, views: ["contentView": contentView]))

        // When a custom offset is available, we adjust the vertical constraints' constants
        if (verticalOffset != 0 && constraints.count > 0) {
            centerYConstraint.constant = verticalOffset
        }
        
        if let customView = customView {
            let centerXConstraint = NSLayoutConstraint(item: customView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)
            let centerYConstraint = NSLayoutConstraint(item: customView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
            
            let customViewHeight = customView.frame.height
            let customViewWidth = customView.frame.width
            var heightConstarint: NSLayoutConstraint!
            var widthConstarint: NSLayoutConstraint!
            
            if(customViewHeight == 0) {
                heightConstarint = NSLayoutConstraint(item: customView, attribute: .height, relatedBy: .lessThanOrEqual, toItem: self, attribute: .height, multiplier: 1, constant: 0.0)
            } else {
                heightConstarint = NSLayoutConstraint(item: customView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: customViewHeight)
            }
            if(customViewWidth == 0) {
                widthConstarint = NSLayoutConstraint(item: customView, attribute: .width, relatedBy: .lessThanOrEqual, toItem: self, attribute: .width, multiplier: 1, constant: 0.0)
            } else {
                widthConstarint = NSLayoutConstraint(item: customView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: customViewWidth)
            }
            
            // When a custom offset is available, we adjust the vertical constraints' constants
            if (verticalOffset != 0) {
                centerYConstraint.constant = verticalOffset
            }
            self.addConstraints([centerXConstraint, centerYConstraint])
            self.addConstraints([heightConstarint, widthConstarint])
//            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[customView]|", options: [], metrics: nil, views: ["customView": customView]))
//            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[customView]|", options: [], metrics: nil, views: ["customView": customView]))
        } else {
            
            let width = frame.width > 0 ? frame.width : UIScreen.main.bounds.width
            let padding = roundf(Float(width/16.0))
            let verticalSpace = self.verticalSpace  // Default is 11 pts
            
            var subviewStrings: [String] = []
            var views: [String: UIView] = [:]
            let metrics = ["padding": padding]
            
            // Assign the image view's horizontal constraints
            if canShowImage {
                imageView.isHidden = false
                
                subviewStrings.append("imageView")
                views[subviewStrings.last!] = imageView
                
                contentView.addConstraint(NSLayoutConstraint.init(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            } else {
                imageView.isHidden = true
            }
            
            // Assign the title label's horizontal constraints
            if (canShowTitle) {
                titleLabel.isHidden = false
                subviewStrings.append("titleLabel")
                views[subviewStrings.last!] = titleLabel
                
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(padding)-[titleLabel(>=0)]-(padding)-|", options: [], metrics: metrics, views: views))
            } else {
                titleLabel.isHidden = true
            }
            
            // Assign the detail label's horizontal constraints
            if (canShowDetail) {
                detailLabel.isHidden = false
                subviewStrings.append("detailLabel")
                views[subviewStrings.last!] = detailLabel

                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(padding)-[detailLabel(>=0)]-(padding)-|", options: [], metrics: metrics, views: views))
            } else {
                detailLabel.isHidden = true
            }
            
            // Assign the button's horizontal constraints
            if (canShowButton) {
                button.isHidden = false
                subviewStrings.append("button")
                views[subviewStrings.last!] = button
                
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(padding)-[button(>=0)]-(padding)-|", options: [], metrics: metrics, views: views))
            } else {
                button.isHidden = true
            }
            
            var verticalFormat = String()
            
            // Build a dynamic string format for the vertical constraints, adding a margin between each element. Default is 11 pts.
            for i in 0 ..< subviewStrings.count {
                let string = subviewStrings[i]
                verticalFormat += "[\(string)]"
                
                if i < subviewStrings.count - 1 {
                    verticalFormat += "-(\(verticalSpace))-"
                }
            }
            
            // Assign the vertical constraints to the content view
            if !verticalFormat.isEmpty {
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|\(verticalFormat)|", options: [], metrics: metrics, views: views))
            }

        }
        
    }
    
}

