//
//  LLCycleScrollView.swift
//  LLCycleScrollView
//
//  Created by LvJianfeng on 2016/11/22.
//  Copyright © 2016年 LvJianfeng. All rights reserved.
//

import UIKit
import Kingfisher

/// Style
public enum PageControlStyle {
    case none
    case system
    case fill
    case pill
    case snake
    case image
}

/// Position
public enum PageControlPosition {
    case center
    case left
    case right
}

/// LLCycleScrollViewDelegate
@objc public protocol LLCycleScrollViewDelegate: class {
    @objc func cycleScrollView(_ cycleScrollView: LLCycleScrollView, didSelectItemIndex index: NSInteger)
    @objc optional func cycleScrollView(_ cycleScrollView: LLCycleScrollView, scrollTo index: NSInteger)
}

/// Closure
public typealias LLdidSelectItemAtIndexClosure = (NSInteger) -> Void


open class LLCycleScrollView: UIView {
    // MAKR: DataSource
    /// Image Paths
    open var imagePaths: Array<String> = [] {
        didSet {
            totalItemsCount = infiniteLoop ? imagePaths.count * 100 : imagePaths.count
            if imagePaths.count > 1 {
                collectionView.isScrollEnabled = true
            }else{
                collectionView.isScrollEnabled = false
                invalidateTimer()
            }
            
            setupPageControl()
            
            collectionView.reloadData()
        }
    }
    
    /// Titles
    open var titles: Array<String> = [] {
        didSet {
            if titles.count > 0 {
                if imagePaths.count == 0 {
                    imagePaths = titles
                }
            }
        }
    }
    
    // MARK:- Closure
    /// 回调
    open var lldidSelectItemAtIndex: LLdidSelectItemAtIndexClosure? = nil
    
    /// 协议
    open weak var delegate: LLCycleScrollViewDelegate?
    
    // MARK:- Config
    /// 自动轮播- 默认true
    open var autoScroll: Bool = true {
        didSet {
            invalidateTimer()
            // 如果关闭的无限循环，则不进行计时器的操作，否则每次滚动到最后一张就不在进行了。
            if autoScroll && infiniteLoop {
                setupTimer()
            }
        }
    }
    
    /// 无限循环- 默认true，此属性修改了就不存在轮播的意义了
    open var infiniteLoop: Bool = true {
        didSet {
            if imagePaths.count > 0 {
                let temp = imagePaths
                imagePaths = temp
            }
        }
    }
    
    /// 滚动方向，默认horizontal
    open var scrollDirection: UICollectionView.ScrollDirection? = .horizontal {
        didSet {
            flowLayout?.scrollDirection = scrollDirection!
            if scrollDirection == .horizontal {
                position = .centeredHorizontally
            }else{
                position = .centeredVertically
            }
        }
    }
    
    /// 滚动间隔时间,默认2秒
    open var autoScrollTimeInterval: Double = 2.0 {
        didSet {
            autoScroll = true
        }
    }
    
    
    // MARK:- Style
    /// Background Color
    open var collectionViewBackgroundColor: UIColor! = UIColor.clear
    
    /// Load Placeholder Image
    open var placeHolderImage: UIImage? = nil {
        didSet {
            if placeHolderImage != nil {
                placeHolderViewImage = placeHolderImage
            }
        }
    }
    
    /// No Data Placeholder Image
    open var coverImage: UIImage? = nil {
        didSet {
            if coverImage != nil {
                coverViewImage = coverImage
            }
        }
    }
    
    // MARK: ImageView
    /// Content Mode
    open var imageViewContentMode: UIView.ContentMode? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    // MARK: Title
    /// Color
    open var textColor: UIColor = UIColor.white
    
    /// Number Lines
    open var numberOfLines: NSInteger = 2
    
    /// Title Leading
    open var titleLeading: CGFloat = 15
    
    /// Font
    open var font: UIFont = UIFont.systemFont(ofSize: 15)
    
    /// Background
    open var titleBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.3)
    
    // MARK: Arrow Icon
    /// Icon - [LeftIcon, RightIcon]
    open var arrowLRIcon: [UIImage]?
    
    /// Icon Frame - [LeftIconFrame, RightIconFrame]
    open var arrowLRFrame: [CGRect]?
    
    // MARK: PageControl
    /// 注意： 由于属性较多，所以请使用style对应的属性，如果没有标明则通用
    /// PageControl
    open var pageControl: UIPageControl?
    
    /// Tint Color
    open var pageControlTintColor: UIColor = UIColor.lightGray {
        didSet {
            setupPageControl()
        }
    }
    // InActive Color
    open var pageControlCurrentPageColor: UIColor = UIColor.white {
        didSet {
            setupPageControl()
        }
    }
    
    /// Radius [PageControlStyle == .fill]
    open var FillPageControlIndicatorRadius: CGFloat = 4 {
        didSet {
            setupPageControl()
        }
    }
    
    /// Active Tint Color [PageControlStyle == .pill || PageControlStyle == .snake]
    open var customPageControlInActiveTintColor: UIColor = UIColor(white: 1, alpha: 0.3) {
        didSet {
            setupPageControl()
        }
    }
    
    /// Active Image [PageControlStyle == .system]
    open var pageControlActiveImage: UIImage? = nil {
        didSet {
            setupPageControl()
        }
    }
    
    /// In Active Image [PageControlStyle == .system]
    open var pageControlInActiveImage: UIImage? = nil {
        didSet {
            setupPageControl()
        }
    }
    
    // MARK: CustomPageControl
    /// Custom PageControl
    open var customPageControl: UIView?
    
    /// Style [.fill, .pill, .snake]
    open var customPageControlStyle: PageControlStyle = .system {
        didSet {
            setupPageControl()
        }
    }
    /// Tint Color
    open var customPageControlTintColor: UIColor = UIColor.white {
        didSet {
            setupPageControl()
        }
    }
    /// Indicator Padding
    open var customPageControlIndicatorPadding: CGFloat = 8 {
        didSet {
            setupPageControl()
        }
    }
    
    /// Position
    open var pageControlPosition: PageControlPosition = .center {
        didSet {
            setupPageControl()
        }
    }
    
    /// Leading
    open var pageControlLeadingOrTrialingContact: CGFloat = 28 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Bottom
    open var pageControlBottom: CGFloat = 11 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 开启/关闭URL特殊字符处理
    open var isAddingPercentEncodingForURLString: Bool = false
    
    
    // MARK:- Private
    /// 总数量
    fileprivate var totalItemsCount: NSInteger! = 1
    
    /// 最大伸展空间(防止出现问题，可外部设置)
    /// 用于反方向滑动的时候，需要知道最大的contentSize
    fileprivate var maxSwipeSize: CGFloat = 0
    
    /// 是否纯文本
    fileprivate var isOnlyTitle: Bool = false
    
    /// 高度
    fileprivate var cellHeight: CGFloat = 56
    
    /// Collection滚动方向
    fileprivate var position: UICollectionView.ScrollPosition! = .centeredHorizontally
    
    /// 加载状态图
    fileprivate var placeHolderViewImage: UIImage! = UIImage(named: "LLCycleScrollView.bundle/llplaceholder.png", in: Bundle(for: LLCycleScrollView.self), compatibleWith: nil)
    
    /// 空数据占位图
    fileprivate var coverViewImage: UIImage! = UIImage(named: "LLCycleScrollView.bundle/llplaceholder.png", in: Bundle(for: LLCycleScrollView.self), compatibleWith: nil)
    
    /// 计时器
    fileprivate var dtimer: DispatchSourceTimer?
    
    /// 容器组件 UICollectionView
    fileprivate var collectionView: UICollectionView!
    
    // Identifier
    fileprivate let identifier = "LLCycleScrollViewCell"
    
    /// UICollectionViewFlowLayout
    lazy fileprivate var flowLayout: UICollectionViewFlowLayout? = {
        let tempFlowLayout = UICollectionViewFlowLayout.init()
        tempFlowLayout.minimumLineSpacing = 0
        tempFlowLayout.scrollDirection = .horizontal
        return tempFlowLayout
    }()
    
    
    /// Init
    ///
    /// - Parameter frame: CGRect
    override internal init(frame: CGRect) {
        super.init(frame: frame)
        setupMainView()
    }
    
    /// Init
    ///
    /// - Parameter aDecoder: NSCoder
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupMainView()
    }
}

// MARK: 类初始化
extension LLCycleScrollView {
    /// 默认初始化
    ///
    /// - Parameters:
    ///   - frame: Frame
    ///   - imageURLPaths: URL Path Array
    ///   - titles: Title Array
    ///   - didSelectItemAtIndex: Closure
    /// - Returns: LLCycleScrollView
    open class func llCycleScrollViewWithFrame(_ frame: CGRect, imageURLPaths: Array<String>? = [], titles:Array<String>? = [], didSelectItemAtIndex: LLdidSelectItemAtIndexClosure? = nil) -> LLCycleScrollView {
        let llcycleScrollView: LLCycleScrollView = LLCycleScrollView.init(frame: frame)
        // Nil
        llcycleScrollView.imagePaths = []
        llcycleScrollView.titles = []
        
        if let imageURLPathList = imageURLPaths, imageURLPathList.count > 0 {
            llcycleScrollView.imagePaths = imageURLPathList
        }
        
        if let titleList = titles, titleList.count > 0 {
            llcycleScrollView.titles = titleList
        }
        
        if didSelectItemAtIndex != nil {
            llcycleScrollView.lldidSelectItemAtIndex = didSelectItemAtIndex
        }
        return llcycleScrollView
    }
    
    /// 纯文本
    ///
    /// - Parameters:
    ///   - frame: Frame
    ///   - backImage: Background Image
    ///   - titles: Title Array
    ///   - didSelectItemAtIndex: Closure
    /// - Returns: LLCycleScrollView
    open class func llCycleScrollViewWithTitles(frame: CGRect, backImage: UIImage? = nil, titles: Array<String>? = [], didSelectItemAtIndex: LLdidSelectItemAtIndexClosure? = nil) -> LLCycleScrollView {
        let llcycleScrollView: LLCycleScrollView = LLCycleScrollView.init(frame: frame)
        // Nil
        llcycleScrollView.titles = []
        
        if let backImage = backImage {
            // 异步加载数据时候，第一个页面会出现placeholder image，可以用backImage来设置纯色图片等其他方式
            llcycleScrollView.coverImage = backImage
        }
        
        // Set isOnlyTitle
        llcycleScrollView.isOnlyTitle = true
        
        // Titles Data
        if let titleList = titles, titleList.count > 0 {
            llcycleScrollView.titles = titleList
        }
        
        if didSelectItemAtIndex != nil {
            llcycleScrollView.lldidSelectItemAtIndex = didSelectItemAtIndex
        }
        return llcycleScrollView
    }
    
    /// 支持箭头初始化
    ///
    /// - Parameters:
    ///   - frame: Frame
    ///   - arrowLRImages: [LeftImage, RightImage]
    ///   - arrowLRPoint: [LeffImage.CGPoint, RightImage.CGPoint], default nil (center)
    ///   - imageURLPaths: URL Path Array
    ///   - titles: Title Array
    ///   - didSelectItemAtIndex: Closure
    /// - Returns: LLCycleScrollView
    open class func llCycleScrollViewWithArrow(_ frame: CGRect, arrowLRImages: [UIImage], arrowLRFrame: [CGRect]? = nil, imageURLPaths: Array<String>? = [], titles:Array<String>? = [], didSelectItemAtIndex: LLdidSelectItemAtIndexClosure? = nil) -> LLCycleScrollView {
        let llcycleScrollView: LLCycleScrollView = LLCycleScrollView.init(frame: frame)
        // Nil
        llcycleScrollView.imagePaths = []
        llcycleScrollView.titles = []
        
        // Images
        llcycleScrollView.arrowLRIcon = arrowLRImages
        llcycleScrollView.arrowLRFrame = arrowLRFrame
        
        // Setup
        llcycleScrollView.setupArrowIcon()
        
        if let imageURLPathList = imageURLPaths, imageURLPathList.count > 0 {
            llcycleScrollView.imagePaths = imageURLPathList
        }
        
        if let titleList = titles, titleList.count > 0 {
            llcycleScrollView.titles = titleList
        }
        
        if didSelectItemAtIndex != nil {
            llcycleScrollView.lldidSelectItemAtIndex = didSelectItemAtIndex
        }
        return llcycleScrollView
    }
}

// MARK: UI
extension LLCycleScrollView {
    // MARK: 添加UICollectionView
    private func setupMainView() {
        collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: flowLayout!)
        collectionView.register(LLCycleScrollViewCell.self, forCellWithReuseIdentifier: identifier)
        collectionView.backgroundColor = collectionViewBackgroundColor
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.scrollsToTop = false
        self.addSubview(collectionView)
    }
    
    // MARK: 添加自定义箭头
    private func setupArrowIcon() {
        if !infiniteLoop {
            assertionFailure("当前未开启无限轮播`infiniteLoop`，请设置后使用此模式.")
            return
        }
        
        guard let ali = arrowLRIcon else {
            assertionFailure("初始化方向图片`arrowLRIcon`数据为空.")
            return
        }
        
        /// 添加默认Frame
        if arrowLRFrame?.count ?? 0 < 2 {
            let w = frame.size.width * 0.25
            let h = frame.size.height
            
            arrowLRFrame = [CGRect.init(x: 5, y: 0, width: w, height: h),
                            CGRect.init(x: frame.size.width - w - 5, y: 0, width: w, height: h)]
        }
        
        guard let alf = arrowLRFrame else {
            assertionFailure("初始化方向图片`arrowLRFrame`数据为空.")
            return
        }
        
        let leftImageView = UIImageView.init(frame: alf.first!)
        leftImageView.contentMode = .left
        leftImageView.tag = 0
        leftImageView.isUserInteractionEnabled = true
        leftImageView.image = ali.first!
        leftImageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(scrollByDirection(_:))))
        self.addSubview(leftImageView)
        
        let rightImageView = UIImageView.init(frame: alf.last!)
        rightImageView.contentMode = .right
        rightImageView.tag = 1
        rightImageView.isUserInteractionEnabled = true
        rightImageView.image = ali.last!
        rightImageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(scrollByDirection(_:))))
        self.addSubview(rightImageView)
    }
    
    // MARK: 添加PageControl
    func setupPageControl() {
        // 重新添加
        if pageControl != nil {
            pageControl?.removeFromSuperview()
        }
        
        if customPageControl != nil {
            customPageControl?.removeFromSuperview()
        }
        
        if imagePaths.count <= 1 {
            return
        }
        
        if customPageControlStyle == .none {
            pageControl = UIPageControl.init()
            pageControl?.numberOfPages = self.imagePaths.count
        }
        
        if customPageControlStyle == .system {
            pageControl = UIPageControl.init()
            pageControl?.pageIndicatorTintColor = pageControlTintColor
            pageControl?.currentPageIndicatorTintColor = pageControlCurrentPageColor
            pageControl?.numberOfPages = self.imagePaths.count
            self.addSubview(pageControl!)
            pageControl?.isHidden = false
        }
        
        if customPageControlStyle == .fill {
            customPageControl = LLFilledPageControl.init(frame: CGRect.zero)
            customPageControl?.tintColor = customPageControlTintColor
            (customPageControl as! LLFilledPageControl).indicatorPadding = customPageControlIndicatorPadding
            (customPageControl as! LLFilledPageControl).indicatorRadius = FillPageControlIndicatorRadius
            (customPageControl as! LLFilledPageControl).pageCount = self.imagePaths.count
            self.addSubview(customPageControl!)
        }
        
        if customPageControlStyle == .pill {
            customPageControl = LLPillPageControl.init(frame: CGRect.zero)
            (customPageControl as! LLPillPageControl).indicatorPadding = customPageControlIndicatorPadding
            (customPageControl as! LLPillPageControl).activeTint = customPageControlTintColor
            (customPageControl as! LLPillPageControl).inactiveTint = customPageControlInActiveTintColor
            (customPageControl as! LLPillPageControl).pageCount = self.imagePaths.count
            self.addSubview(customPageControl!)
        }
        
        if customPageControlStyle == .snake {
            customPageControl = LLSnakePageControl.init(frame: CGRect.zero)
            (customPageControl as! LLSnakePageControl).activeTint = customPageControlTintColor
            (customPageControl as! LLSnakePageControl).indicatorPadding = customPageControlIndicatorPadding
            (customPageControl as! LLSnakePageControl).indicatorRadius = FillPageControlIndicatorRadius
            (customPageControl as! LLSnakePageControl).inactiveTint = customPageControlInActiveTintColor
            (customPageControl as! LLSnakePageControl).pageCount = self.imagePaths.count
            self.addSubview(customPageControl!)
        }
        
        if customPageControlStyle == .image {
            pageControl = LLImagePageControl()
            pageControl?.pageIndicatorTintColor = UIColor.clear
            pageControl?.currentPageIndicatorTintColor = UIColor.clear
            
            if let activeImage = pageControlActiveImage {
                (pageControl as? LLImagePageControl)?.dotActiveImage = activeImage
            }
            if let inActiveImage = pageControlInActiveImage {
                (pageControl as? LLImagePageControl)?.dotInActiveImage = inActiveImage
            }
            
            pageControl?.numberOfPages = self.imagePaths.count
            self.addSubview(pageControl!)
            pageControl?.isHidden = false
        }
    }
}

// MARK: UIViewHierarchy | LayoutSubviews
extension LLCycleScrollView {
    /// 将要添加到 window 上时
    ///
    /// - Parameter newWindow: 新的 window
    /// 添加到window 上时 开启 timer, 从 window 上移除时, 移除 timer
    override open func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            if autoScroll && infiniteLoop {
                setupTimer()
            }
        } else {
            invalidateTimer()
        }
    }
    
    // MARK: layoutSubviews
    override open func layoutSubviews() {
        super.layoutSubviews()
        // CollectionView
        collectionView.frame = self.bounds
        
        // Cell Height
        cellHeight = collectionView.frame.height
        
        // 计算最大扩展区大小
        if scrollDirection == .horizontal {
            maxSwipeSize = CGFloat(imagePaths.count) * collectionView.frame.width
        }else{
            maxSwipeSize = CGFloat(imagePaths.count) * collectionView.frame.height
        }
        
        // Cell Size
        flowLayout?.itemSize = self.frame.size
        // Page Frame
        if customPageControlStyle == .none || customPageControlStyle == .system || customPageControlStyle == .image {
            if pageControlPosition == .center {
                pageControl?.frame = CGRect.init(x: 0, y: self.ll_h-pageControlBottom, width: UIScreen.main.bounds.width, height: 10)
            }else{
                let pointSize = pageControl?.size(forNumberOfPages: self.imagePaths.count)
                if pageControlPosition == .left {
                    pageControl?.frame = CGRect.init(x: -(UIScreen.main.bounds.width - (pointSize?.width)! - pageControlLeadingOrTrialingContact) * 0.5, y: self.ll_h-pageControlBottom, width: UIScreen.main.bounds.width, height: 10)
                }else{
                    pageControl?.frame = CGRect.init(x: (UIScreen.main.bounds.width - (pointSize?.width)! - pageControlLeadingOrTrialingContact) * 0.5, y: self.ll_h-pageControlBottom, width: UIScreen.main.bounds.width, height: 10)
                }
            }
        }else{
            var y = self.ll_h-pageControlBottom
            
            // pill
            if customPageControlStyle == .pill {
                y+=5
            }
            
            let oldFrame = customPageControl?.frame
            switch pageControlPosition {
            case .left:
                customPageControl?.frame = CGRect.init(x: pageControlLeadingOrTrialingContact * 0.5, y: y, width: (oldFrame?.size.width)!, height: 10)
            case.right:
                customPageControl?.frame = CGRect.init(x: UIScreen.main.bounds.width - (oldFrame?.size.width)! - pageControlLeadingOrTrialingContact * 0.5, y: y, width: (oldFrame?.size.width)!, height: 10)
            default:
                customPageControl?.frame = CGRect.init(x: (oldFrame?.origin.x)!, y: y, width: (oldFrame?.size.width)!, height: 10)
            }
        }
        
        if collectionView.contentOffset.x == 0 && totalItemsCount > 0 {
            var targetIndex = 0
            if infiniteLoop {
                targetIndex = totalItemsCount/2
            }
            collectionView.scrollToItem(at: IndexPath.init(item: targetIndex, section: 0), at: position, animated: false)
        }
    }
}

// MARK: 定时器模块
extension LLCycleScrollView {
    /// 添加DTimer
    func setupTimer() {
        // 仅一张图不进行滚动操纵
        if self.imagePaths.count <= 1 { return }
        
        let l_dtimer = DispatchSource.makeTimerSource()
        l_dtimer.schedule(deadline: .now()+autoScrollTimeInterval, repeating: autoScrollTimeInterval)
        l_dtimer.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                self?.automaticScroll()
            }
        }
        // 继续
        l_dtimer.resume()
        
        dtimer = l_dtimer
    }
    
    /// 关闭倒计时
    func invalidateTimer() {
        dtimer?.cancel()
        dtimer = nil
    }
}

// MARK: Events
extension LLCycleScrollView {
    /// 自动轮播
    @objc func automaticScroll() {
        if totalItemsCount == 0 {return}
        let targetIndex = currentIndex() + 1
        scollToIndex(targetIndex: targetIndex)
    }
    
    /// 滚动到指定位置
    ///
    /// - Parameter targetIndex: 下标-Index
    func scollToIndex(targetIndex: Int) {
        if targetIndex >= totalItemsCount {
            if infiniteLoop {
                collectionView.scrollToItem(at: IndexPath.init(item: Int(totalItemsCount/2), section: 0), at: position, animated: false)
            }
            return
        }
        collectionView.scrollToItem(at: IndexPath.init(item: targetIndex, section: 0), at: position, animated: true)
    }
    
    /// 当前位置
    ///
    /// - Returns: 下标-Index
    func currentIndex() -> NSInteger {
        if collectionView.ll_w == 0 || collectionView.ll_h == 0 {
            return 0
        }
        var index = 0
        if flowLayout?.scrollDirection == UICollectionView.ScrollDirection.horizontal {
            index = NSInteger(collectionView.contentOffset.x + (flowLayout?.itemSize.width)! * 0.5)/NSInteger((flowLayout?.itemSize.width)!)
        }else {
            index = NSInteger(collectionView.contentOffset.y + (flowLayout?.itemSize.height)! * 0.5)/NSInteger((flowLayout?.itemSize.height)!)
        }
        return index
    }
    
    /// PageControl当前下标对应的Cell位置
    ///
    /// - Parameter index: PageControl Index
    /// - Returns: Cell Index
    func pageControlIndexWithCurrentCellIndex(index: NSInteger) -> (Int) {
        return imagePaths.count == 0 ? 0 : Int(index % imagePaths.count)
    }
    
    /// 滚动上一个/下一个
    ///
    /// - Parameter gesture: 手势
    @objc open func scrollByDirection(_ gestureRecognizer: UITapGestureRecognizer) {
        if let index = gestureRecognizer.view?.tag {
            if autoScroll {
                invalidateTimer()
            }
            
            scollToIndex(targetIndex: currentIndex() + (index == 0 ? -1 : 1))
        }
    }
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource
extension LLCycleScrollView: UICollectionViewDelegate, UICollectionViewDataSource {
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalItemsCount == 0 ? 1:totalItemsCount
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LLCycleScrollViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! LLCycleScrollViewCell
        // Setting
        cell.titleFont = font
        cell.titleLabelTextColor = textColor
        cell.titleBackViewBackgroundColor = titleBackgroundColor
        cell.titleLines = numberOfLines
        
        // Leading
        cell.titleLabelLeading = titleLeading
        
        // Only Title
        if isOnlyTitle && titles.count > 0{
            cell.titleLabelHeight = cellHeight
            
            let itemIndex = pageControlIndexWithCurrentCellIndex(index: indexPath.item)
            cell.title = titles[itemIndex]
        }else{
            // Mode
            if let imageViewContentMode = imageViewContentMode {
                cell.imageView.contentMode = imageViewContentMode
            }
            
            // 0==count 占位图
            if imagePaths.count == 0 {
                cell.imageView.image = coverViewImage
            }else{
                let itemIndex = pageControlIndexWithCurrentCellIndex(index: indexPath.item)
                let imagePath = imagePaths[itemIndex]
                
                // 根据imagePath，来判断是网络图片还是本地图
                if imagePath.hasPrefix("http") {
                    let escapedString = imagePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    cell.imageView.kf.setImage(with: URL(string: isAddingPercentEncodingForURLString ? escapedString ?? imagePath : imagePath), placeholder: placeHolderImage)
                }else{
                    if let image = UIImage.init(named: imagePath) {
                        cell.imageView.image = image;
                    }else{
                        cell.imageView.image = UIImage.init(contentsOfFile: imagePath)
                    }
                }
                
                // 对冲数据判断
                if itemIndex <= titles.count-1 {
                    cell.title = titles[itemIndex]
                }else{
                    cell.title = ""
                }
            }
        }
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let didSelectItemAtIndexPath = lldidSelectItemAtIndex {
            didSelectItemAtIndexPath(pageControlIndexWithCurrentCellIndex(index: indexPath.item))
        }else if let delegate = delegate {
            delegate.cycleScrollView(self, didSelectItemIndex: pageControlIndexWithCurrentCellIndex(index: indexPath.item))
        }
    }
}

// MARK: UIScrollViewDelegate
extension LLCycleScrollView: UIScrollViewDelegate {
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if imagePaths.count == 0 { return }
        let indexOnPageControl = pageControlIndexWithCurrentCellIndex(index: currentIndex())
        if customPageControlStyle == .none || customPageControlStyle == .system || customPageControlStyle == .image {
            pageControl?.currentPage = indexOnPageControl
        }else{
            var progress: CGFloat = 999
            // Direction
            if scrollDirection == .horizontal {
                var currentOffsetX = scrollView.contentOffset.x - (CGFloat(totalItemsCount) * scrollView.frame.size.width) / 2
                if currentOffsetX < 0 {
                    if currentOffsetX >= -scrollView.frame.size.width{
                        currentOffsetX = CGFloat(indexOnPageControl) * scrollView.frame.size.width
                    }else if currentOffsetX <= -maxSwipeSize{
                        collectionView.scrollToItem(at: IndexPath.init(item: Int(totalItemsCount/2), section: 0), at: position, animated: false)
                    }else{
                        currentOffsetX = maxSwipeSize + currentOffsetX
                    }
                }
                if currentOffsetX >= CGFloat(self.imagePaths.count) * scrollView.frame.size.width && infiniteLoop{
                    collectionView.scrollToItem(at: IndexPath.init(item: Int(totalItemsCount/2), section: 0), at: position, animated: false)
                }
                progress = currentOffsetX / scrollView.frame.size.width
            }else if scrollDirection == .vertical{
                var currentOffsetY = scrollView.contentOffset.y - (CGFloat(totalItemsCount) * scrollView.frame.size.height) / 2
                if currentOffsetY < 0 {
                    if currentOffsetY >= -scrollView.frame.size.height{
                        currentOffsetY = CGFloat(indexOnPageControl) * scrollView.frame.size.height
                    }else if currentOffsetY <= -maxSwipeSize{
                        collectionView.scrollToItem(at: IndexPath.init(item: Int(totalItemsCount/2), section: 0), at: position, animated: false)
                    }else{
                        currentOffsetY = maxSwipeSize + currentOffsetY
                    }
                }
                if currentOffsetY >= CGFloat(self.imagePaths.count) * scrollView.frame.size.height && infiniteLoop{
                    collectionView.scrollToItem(at: IndexPath.init(item: Int(totalItemsCount/2), section: 0), at: position, animated: false)
                }
                progress = currentOffsetY / scrollView.frame.size.height
            }
            
            if progress == 999 {
                progress = CGFloat(indexOnPageControl)
            }
            // progress
            if customPageControlStyle == .fill {
                (customPageControl as? LLFilledPageControl)?.progress = progress
            }else if customPageControlStyle == .pill {
                (customPageControl as? LLPillPageControl)?.progress = progress
            }else if customPageControlStyle == .snake {
                (customPageControl as? LLSnakePageControl)?.progress = progress
            }
        }
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if autoScroll {
            invalidateTimer()
        }
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if imagePaths.count == 0 { return }
        let indexOnPageControl = pageControlIndexWithCurrentCellIndex(index: currentIndex())
        
        // 滚动后的回调协议
        delegate?.cycleScrollView?(self, scrollTo: indexOnPageControl)
        
        if autoScroll {
            setupTimer()
        }
    }
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if imagePaths.count == 0 { return }
        let indexOnPageControl = pageControlIndexWithCurrentCellIndex(index: currentIndex())
        
        // 滚动后的回调协议
        delegate?.cycleScrollView?(self, scrollTo: indexOnPageControl)
        
        if dtimer == nil && autoScroll {
            setupTimer()
        }
    }
}
