//
//  UPageViewController.swift
//  U17
//
//  Created by charles on 2017/10/24.
//  Copyright © 2017年 None. All rights reserved.
//

import UIKit
import HMSegmentedControl

enum UPageStyle {
    case none
    case navgationBarSegment
    case topTabBar
}

class UPageViewController: UBaseViewController {
    
    var pageStyle: UPageStyle!
    
    lazy var segment: HMSegmentedControl = {
        return HMSegmentedControl().then{
            $0.addTarget(self, action: #selector(changeIndex(segment:)), for: .valueChanged)
        }
    }()
    
    lazy var pageVC: UIPageViewController = {
        return UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }()
    
    private(set) var vcs: [UIViewController]!
    private(set) var titles:[String]!
    private var currentSelectIndex: Int = 0
    
    
    convenience init(titles: [String] = [], vcs: [UIViewController] = [], pageStyle: UPageStyle = .none) {
        self.init()
        self.titles = titles
        self.vcs = vcs
        self.pageStyle = pageStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func changeIndex(segment: UISegmentedControl) {
        let index = segment.selectedSegmentIndex
        if currentSelectIndex != index {
            let target:[UIViewController] = [vcs[index]]
            let direction:UIPageViewControllerNavigationDirection = currentSelectIndex > index ? .reverse : .forward
            pageVC.setViewControllers(target, direction: direction, animated: false) { [weak self] (finish) in
                self?.currentSelectIndex = index
            }
        }
    }
    
    override func configUI() {
        guard let vcs = vcs else { return }
        addChildViewController(pageVC)
        view.addSubview(pageVC.view)
        
        pageVC.dataSource = self
        pageVC.delegate = self
        pageVC.setViewControllers([vcs[0]], direction: .forward, animated: false, completion: nil)
        
        switch pageStyle {
        case .none:
            pageVC.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        case .navgationBarSegment:
            segment.backgroundColor = UIColor.clear
            segment.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.5),
                                           NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20)]
            segment.selectedTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white,
                                                   NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20)]
            segment.selectionIndicatorLocation = .none
            
            navigationItem.titleView = segment
            segment.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 120, height: 40)
            
            pageVC.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        case .topTabBar:
            segment.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black,
                                           NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)]
            segment.selectedTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(r: 127, g: 221, b: 146),
                                                   NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)]
            segment.selectionIndicatorLocation = .down
            segment.selectionIndicatorColor = UIColor(r: 127, g: 221, b: 146)
            segment.selectionIndicatorHeight = 2
            segment.borderType = .bottom
            segment.borderColor = UIColor.lightGray
            segment.borderWidth = 0.5
            
            view.addSubview(segment)
            segment.snp.makeConstraints{
                $0.top.left.right.equalToSuperview()
                $0.height.equalTo(40)
            }
            
            pageVC.view.snp.makeConstraints{
                $0.top.equalTo(segment.snp.bottom)
                $0.left.right.bottom.equalToSuperview()
            }
        default: break
        }
        
        guard let titles = titles else { return }
        segment.sectionTitles = titles
        currentSelectIndex = 0
        segment.selectedSegmentIndex = currentSelectIndex
    }
}

extension UPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = vcs.index(of: viewController) else { return nil }
        let beforeIndex = index - 1
        guard beforeIndex >= 0 else { return nil }
        return vcs[beforeIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = vcs.index(of: viewController) else { return nil }
        let afterIndex = index + 1
        guard afterIndex <= vcs.count - 1 else { return nil }
        return vcs[afterIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let viewController = pageViewController.viewControllers?.last,
            let index = vcs.index(of: viewController) else {
                return
        }
        currentSelectIndex = index
        segment.setSelectedSegmentIndex(UInt(index), animated: true)
        guard titles != nil && pageStyle == .none else { return }
        navigationItem.title = titles[index]
    }
}








