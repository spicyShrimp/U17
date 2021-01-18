# EmptyDataSet-Swift
![pod](https://img.shields.io/badge/pod-5.0.0-brightgreen.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![iOS](https://img.shields.io/badge/iOS-8.0-green.svg)
![lisence](https://img.shields.io/badge/license-MIT-orange.svg)
![swift](https://img.shields.io/badge/swift-5.0-red.svg)

A drop-in UITableView/UICollectionView superclass category for showing empty datasets whenever the view has no content to display.  [DZNEmptyDataSet](https://github.com/dzenbot/DZNEmptyDataSet/blob/master/README.md) with Swift.

## ScreenShot

![Screenshots_row1](Example/ScreenShot/Screenshots_row1.png)

![Screenshots_row2](Example/ScreenShot/Screenshots_row2.png)

## Installation

### CocoaPods
```
pod 'EmptyDataSet-Swift', '~> 5.0.0'
```

### Carthage

```
github "Xiaoye220/EmptyDataSet-Swift" "4.2.0"
```

## Usage
### Basic 
Same as [DZNEmptyDataSet](https://github.com/dzenbot/DZNEmptyDataSet/blob/master/README.md)

```swift
import EmptyDataSet_Swift

class OriginalUsageViewController: UITableViewController, EmptyDataSetSource, EmptyDataSetDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
}
```
#### EmptyDataSetDelegate
```swift
public protocol EmptyDataSetDelegate: class {

    /// Asks the delegate to know if the empty dataset should fade in when displayed. Default is true.
    func emptyDataSetShouldFadeIn(_ scrollView: UIScrollView) -> Bool
    
    /// Asks the delegate to know if the empty dataset should still be displayed when the amount of items is more than 0. Default is false.
    func emptyDataSetShouldBeForcedToDisplay(_ scrollView: UIScrollView) -> Bool

    /// Asks the delegate to know if the empty dataset should be rendered and displayed. Default is true.
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool

    /// Asks the delegate for touch permission. Default is true.
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView) -> Bool

    /// Asks the delegate for scroll permission. Default is false.
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool

    /// Asks the delegate for image view animation permission. Default is false.
    /// Make sure to return a valid CAAnimation object from imageAnimationForEmptyDataSet:
    func emptyDataSetShouldAnimateImageView(_ scrollView: UIScrollView) -> Bool

    /// Tells the delegate that the empty dataset view was tapped.
    /// Use this method either to resignFirstResponder of a textfield or searchBar.
    func emptyDataSet(_ scrollView: UIScrollView, didTapView view: UIView)

    /// Tells the delegate that the action button was tapped.
    func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton)

    /// Tells the delegate that the empty data set will appear.
    func emptyDataSetWillAppear(_ scrollView: UIScrollView)

    /// Tells the delegate that the empty data set did appear.
    func emptyDataSetDidAppear(_ scrollView: UIScrollView)

    /// Tells the delegate that the empty data set will disappear.
    func emptyDataSetWillDisappear(_ scrollView: UIScrollView)

    /// Tells the delegate that the empty data set did disappear.
    func emptyDataSetDidDisappear(_ scrollView: UIScrollView)
}
```

#### EmptyDataSetSource
```swift
public protocol EmptyDataSetSource: class {

    /// Asks the data source for the title of the dataset.
    /// The dataset uses a fixed font style by default, if no attributes are set. If you want a different font style, return a attributed string.
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString?
    
    /// Asks the data source for the description of the dataset.
    /// The dataset uses a fixed font style by default, if no attributes are set. If you want a different font style, return a attributed string.
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString?
    
    /// Asks the data source for the image of the dataset.
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage?
    
    /// Asks the data source for a tint color of the image dataset. Default is nil.
    func imagetintColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor?

    /// Asks the data source for the image animation of the dataset.
    func imageAnimation(forEmptyDataSet scrollView: UIScrollView) -> CAAnimation?
    
    /// Asks the data source for the title to be used for the specified button state.
    /// The dataset uses a fixed font style by default, if no attributes are set. If you want a different font style, return a attributed string.
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControlState) -> NSAttributedString?
    
    /// Asks the data source for the image to be used for the specified button state.
    /// This method will override buttonTitleForEmptyDataSet:forState: and present the image only without any text.
    func buttonImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControlState) -> UIImage?
    
    /// Asks the data source for a background image to be used for the specified button state.
    /// There is no default style for this call.
    func buttonBackgroundImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControlState) -> UIImage?

    /// Asks the data source for the background color of the dataset. Default is clear color.
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor?

    /// Asks the data source for a custom view to be displayed instead of the default views such as labels, imageview and button. Default is nil.
    /// Use this method to show an activity view indicator for loading feedback, or for complete custom empty data set.
    /// Returning a custom view will ignore -offsetForEmptyDataSet and -spaceHeightForEmptyDataSet configurations.
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView?

    /// Asks the data source for a offset for vertical alignment of the content. Default is 0.
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat

    /// Asks the data source for a vertical space between elements. Default is 11 pts.
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView) -> CGFloat
}
```

### Extensions
Usage without conform to datasource and/or delegate.Tableview just calls the following method.

```swift
public func emptyDataSetView(_ closure: @escaping (EmptyDataSetView) -> Void)
```

Example:

```swift
tableView.emptyDataSetView { view in
    view.titleLabelString(titleString)
        .detailLabelString(detailString)
        .image(image)
        .imageAnimation(imageAnimation)
        .buttonTitle(buttonTitle, for: .normal)
        .buttonTitle(buttonTitle, for: .highlighted)
        .buttonBackgroundImage(buttonBackgroundImage, for: .normal)
        .buttonBackgroundImage(buttonBackgroundImage, for: .highlighted)
        .dataSetBackgroundColor(backgroundColor)
        .verticalOffset(verticalOffset)
        .verticalSpace(spaceHeight)
        .shouldDisplay(true, view: tableView)
        .shouldFadeIn(true)
        .isTouchAllowed(true)
        .isScrollAllowed(true)
        .isImageViewAnimateAllowed(isLoading)
        .didTapDataButton {
            // Do something
        }
        .didTapContentView {
            // Do something
        }
}

```

### About CustomView
Set customView by using EmptyDataSetSource, other setting will be invalid.Set customView by using Extensions, other autolayout will be invalid.

Rule for displaying CustomView
1. CustomView will Display in the center of tableView
2. The verticalOffset of customView can be setted by ```func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat```
3. The width and height is equel to the frame of customView.But if the customView is UILabel and it's frame is CGRect.zero,it's width and height will be autolayout by it's content.

**Example:**

#### Rule 1
```swift
func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
    let view = CustomView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
    return view
}
```
```swift
tableView.emptyDataSetView { [weak self] view in
    view.customView(CustomView(frame: CGRect(x: 0, y: 0, width: 150, height: 150)))
}
```
above code will show as follows

![CustomScreenShot_1](Example/ScreenShot/CustomViewScreenShot_1.png)

#### Rule 2

```swift
func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
    let view = CustomView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
    return view
}
func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
    return 200
}
```
```swift
tableView.emptyDataSetView { [weak self] view in
    view.customView(CustomView(frame: CGRect(x: 0, y: 0, width: 150, height: 150)))
        .verticalOffset(200)
}
```

above code will show as follows

![CustomScreenShot_2](Example/ScreenShot/CustomViewScreenShot_2.png)

#### Rule 3

```swift
func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
    let label = UILabel()
    label.text = "CustomView"
    label.backgroundColor = UIColor.red
    return label
}
```

above code will show as follows

![CustomScreenShot_3](Example/ScreenShot/CustomViewScreenShot_3.png)
