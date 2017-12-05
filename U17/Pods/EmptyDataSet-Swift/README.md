# EmptyDataSet-Swift
![pod](https://img.shields.io/badge/pod-4.0.2-brightgreen.svg)
![iOS](https://img.shields.io/badge/iOS-8.0-green.svg)
![lisence](https://img.shields.io/badge/license-MIT-orange.svg)
![swift](https://img.shields.io/badge/swift-4.0-red.svg)

当 UITableView/UICollectionView  数据为空时显示占位图

>A drop-in UITableView/UICollectionView superclass category for showing empty datasets whenever the view has no content to display. DZNEmptyDataSet with Swift.

## ScreenShot

![ScreenShot](https://github.com/Xiaoye220/EmptyDataSet-Swift/blob/master/EmptyDataSet-Swift/ScreenShot/ScreenShot.gif)

## CocoaPods
```
use_frameworks!
pod 'EmptyDataSet-Swift', '~> 4.0.2'
```


## Usage
### Basic 
基本用法和 [DZNEmptyDataSet](https://github.com/dzenbot/DZNEmptyDataSet/blob/master/README.md) 一样

>Same as [DZNEmptyDataSet](https://github.com/dzenbot/DZNEmptyDataSet/blob/master/README.md)

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
除了 DZNEmptyDataSet 中介绍的用法，另外拓展了不需要通过实现协议 DZNEmptyDataSetSource 和 DZNEmptyDataSetDelegate 的用法。
只要给需要的 tableView 调用下面方法

>Usage without conform to datasource and/or delegate.Tableview just calls the following method.

```swift
public func emptyDataSetView(_ closure: @escaping (EmptyDataSetView) -> Void)
```

像这样子使用

>Like this

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

### CustomView
**注意:** 通过 EmptyDataSetSource 设置了 CustomView 其他设置都会无效。通过链式方式设置 CustomView 其他控件的自动布局会无效。

>Set customView with EmptyDataSetSource, other setting will be invalid.Set customView with Extensions, other autolayout will be invalid.

```swift
func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
    let view = UIView()
    view.frame = CGRect.init(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 100)
    view.backgroundColor = UIColor.lightGray

    let label = UILabel()
    label.frame = CGRect.init(x: 0, y: 10, width: UIScreen.main.bounds.width, height: 40)
    label.text = "Test CustomView"

    view.addSubview(label)

    return view
}
```
上述代码显示效果如下:

>will show as follows

![CustomScreenShot](https://github.com/Xiaoye220/EmptyDataSet-Swift/blob/master/EmptyDataSet-Swift/ScreenShot/CustomViewScreenShot.png)
