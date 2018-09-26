//
//  Protocols.swift
//  EmptyDataSet-Swift
//
//  Created by YZF on 27/6/17.
//  Copyright © 2017年 Xiaoye. All rights reserved.
//

import Foundation
import UIKit


/// The object that acts as the data source of the empty datasets.
/// @discussion The data source must adopt the DZNEmptyDataSetSource protocol. The data source is not retained. All data source methods are optional.
public protocol EmptyDataSetSource {
    
    /// Asks the data source for the title of the dataset.
    /// The dataset uses a fixed font style by default, if no attributes are set. If you want a different font style, return a attributed string.
    ///
    /// - Parameter scrollView: scrollView A scrollView subclass informing the data source.
    /// - Returns: An attributed string for the dataset title, combining font, text color, text pararaph style, etc.
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString?
    
    /// Asks the data source for the description of the dataset.
    /// The dataset uses a fixed font style by default, if no attributes are set. If you want a different font style, return a attributed string.
    ///
    /// - Parameter scrollView: scrollView A scrollView subclass informing the data source.
    /// - Returns: An attributed string for the dataset description text, combining font, text color, text pararaph style, etc.
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString?
    
    /// Asks the data source for the image of the dataset.
    ///
    /// - Parameter scrollView: A scrollView subclass informing the data source.
    /// - Returns: An image for the dataset.
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage?
    
    /// Asks the data source for a tint color of the image dataset. Default is nil.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the data source.
    /// - Returns: A color to tint the image of the dataset.
    func imagetintColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor?

    /// Asks the data source for the image animation of the dataset.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: image animation
    func imageAnimation(forEmptyDataSet scrollView: UIScrollView) -> CAAnimation?
    
    /// Asks the data source for the title to be used for the specified button state.
    /// The dataset uses a fixed font style by default, if no attributes are set. If you want a different font style, return a attributed string.
    ///
    /// - Parameters:
    ///   - scrollView: A scrollView subclass object informing the data source.
    ///   - forState: The state that uses the specified title. The possible values are described in UIControlState.
    /// - Returns: An attributed string for the dataset button title, combining font, text color, text pararaph style, etc.
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString?
    
    /// Asks the data source for the image to be used for the specified button state.
    /// This method will override buttonTitleForEmptyDataSet:forState: and present the image only without any text.
    ///
    /// - Parameters:
    ///   - scrollView: A scrollView subclass object informing the data source.
    ///   - forState: The state that uses the specified title. The possible values are described in UIControlState.
    /// - Returns: An image for the dataset button imageview.
    func buttonImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage?
    
    /// Asks the data source for a background image to be used for the specified button state.
    /// There is no default style for this call.
    ///
    /// - Parameters:
    ///   - scrollView: A scrollView subclass informing the data source.
    ///   - forState: The state that uses the specified image. The values are described in UIControlState.
    /// - Returns: An attributed string for the dataset button title, combining font, text color, text pararaph style, etc.
    func buttonBackgroundImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage?

    /// Asks the data source for the background color of the dataset. Default is clear color.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the data source.
    /// - Returns: A color to be applied to the dataset background view.
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor?

    /// Asks the data source for a custom view to be displayed instead of the default views such as labels, imageview and button. Default is nil.
    /// Use this method to show an activity view indicator for loading feedback, or for complete custom empty data set.
    /// Returning a custom view will ignore -offsetForEmptyDataSet and -spaceHeightForEmptyDataSet configurations.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: The custom view.
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView?

    /// Asks the data source for a offset for vertical alignment of the content. Default is 0.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: The offset for vertical alignment.
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat

    /// Asks the data source for a vertical space between elements. Default is 11 pts.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: The space height between elements.
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView) -> CGFloat

}

public extension EmptyDataSetSource {
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return nil
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return nil
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return nil
    }
    
    func imagetintColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        return nil
    }
    
    func imageAnimation(forEmptyDataSet scrollView: UIScrollView) -> CAAnimation? {
        return nil
    }
 
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        return nil
    }
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage? {
        return nil
    }

    func buttonBackgroundImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage? {
        return nil
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        return nil
    }
    
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        return nil
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return 0
    }
 
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return 11
    }
}
