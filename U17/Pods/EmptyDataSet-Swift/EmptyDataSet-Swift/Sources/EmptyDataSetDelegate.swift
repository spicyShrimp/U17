//
//  EmptyDataSetDelegate.swift
//  EmptyDataSet-Swift
//
//  Created by YZF on 27/6/17.
//  Copyright © 2017年 Xiaoye. All rights reserved.
//

import Foundation
import UIKit


/// The object that acts as the delegate of the empty datasets.
/// @discussion The delegate can adopt the DZNEmptyDataSetDelegate protocol. The delegate is not retained. All delegate methods are optional.
///
/// @discussion All delegate methods are optional. Use this delegate for receiving action callbacks.
public protocol EmptyDataSetDelegate {
    
    /// Asks the delegate to know if the empty dataset should fade in when displayed. Default is true.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: true if the empty dataset should fade in.
    func emptyDataSetShouldFadeIn(_ scrollView: UIScrollView) -> Bool
    
    /// Asks the delegate to know if the empty dataset should still be displayed when the amount of items is more than 0. Default is false.
    ///
    /// - Parameter scrollView:  A scrollView subclass object informing the delegate.
    /// - Returns: true if empty dataset should be forced to display
    func emptyDataSetShouldBeForcedToDisplay(_ scrollView: UIScrollView) -> Bool

    /// Asks the delegate to know if the empty dataset should be rendered and displayed. Default is true.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: true if the empty dataset should show.
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool

    /// Asks the delegate for touch permission. Default is true.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: true if the empty dataset receives touch gestures.
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView) -> Bool

    /// Asks the delegate for scroll permission. Default is false.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: true if the empty dataset is allowed to be scrollable.
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool

    /// Asks the delegate for image view animation permission. Default is false.
    /// Make sure to return a valid CAAnimation object from imageAnimationForEmptyDataSet:
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: true if the empty dataset is allowed to animate
    func emptyDataSetShouldAnimateImageView(_ scrollView: UIScrollView) -> Bool

    /// Tells the delegate that the empty dataset view was tapped.
    /// Use this method either to resignFirstResponder of a textfield or searchBar.
    ///
    /// - Parameters:
    ///   - scrollView: scrollView A scrollView subclass informing the delegate.
    ///   - view: the view tapped by the user
    func emptyDataSet(_ scrollView: UIScrollView, didTapView view: UIView)

    /// Tells the delegate that the action button was tapped.
    ///
    /// - Parameters:
    ///   - scrollView: A scrollView subclass informing the delegate.
    ///   - button: the button tapped by the user
    func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton)

    /// Tells the delegate that the empty data set will appear.
    ///
    /// - Parameter scrollView: A scrollView subclass informing the delegate.
    func emptyDataSetWillAppear(_ scrollView: UIScrollView)

    /// Tells the delegate that the empty data set did appear.
    ///
    /// - Parameter scrollView: A scrollView subclass informing the delegate.
    func emptyDataSetDidAppear(_ scrollView: UIScrollView)

    /// Tells the delegate that the empty data set will disappear.
    ///
    /// - Parameter scrollView: A scrollView subclass informing the delegate.
    func emptyDataSetWillDisappear(_ scrollView: UIScrollView)

    /// Tells the delegate that the empty data set did disappear.
    ///
    /// - Parameter scrollView: A scrollView subclass informing the delegate.
    func emptyDataSetDidDisappear(_ scrollView: UIScrollView)

}

public extension EmptyDataSetDelegate {
    
    func emptyDataSetShouldFadeIn(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    
    func emptyDataSetShouldBeForcedToDisplay(_ scrollView: UIScrollView) -> Bool {
        return false
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return false
    }
    
    func emptyDataSetShouldAnimateImageView(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTapView view: UIView) {
        
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton) {
        
    }
    
    func emptyDataSetWillAppear(_ scrollView: UIScrollView) {
        
    }
    
    func emptyDataSetDidAppear(_ scrollView: UIScrollView) {
        
    }
    
    func emptyDataSetWillDisappear(_ scrollView: UIScrollView) {
        
    }
    
    func emptyDataSetDidDisappear(_ scrollView: UIScrollView) {
        
    }
    
}
