//
//  UCollectionViewSectionBackgroundLayoutLayout.swift
//  U17
//
//  Created by charles on 2017/11/9.
//  Copyright © 2017年 None. All rights reserved.
//

import UIKit

private let SectionBackground = "UCollectionReusableView"

protocol UCollectionViewSectionBackgroundLayoutDelegateLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        backgroundColorForSectionAt section: Int) -> UIColor
}

extension UCollectionViewSectionBackgroundLayoutDelegateLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        backgroundColorForSectionAt section: Int) -> UIColor {
        return collectionView.backgroundColor ?? UIColor.clear
    }
}

private class UCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    var backgroundColor = UIColor.white
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! UCollectionViewLayoutAttributes
        copy.backgroundColor = self.backgroundColor
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? UCollectionViewLayoutAttributes else {
            return false
        }
        
        if !self.backgroundColor.isEqual(rhs.backgroundColor) {
            return false
        }
        return super.isEqual(object)
    }
}

private class UCollectionReusableView: UICollectionReusableView {
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        guard let attr = layoutAttributes as? UCollectionViewLayoutAttributes else {
            return
        }
        
        self.backgroundColor = attr.backgroundColor
    }
}

class UCollectionViewSectionBackgroundLayout: UICollectionViewFlowLayout {
    
    private var decorationViewAttrs: [UICollectionViewLayoutAttributes] = []

    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        self.register(UCollectionReusableView.classForCoder(), forDecorationViewOfKind: SectionBackground)
    }
    
    
    override func prepare() {
        super.prepare()
        guard let numberOfSections = self.collectionView?.numberOfSections,
            let delegate = self.collectionView?.delegate as? UCollectionViewSectionBackgroundLayoutDelegateLayout
            else {
                return
        }
        
        self.decorationViewAttrs.removeAll()
        for section in 0..<numberOfSections {
            let indexPath = IndexPath(item: 0, section: section)
            
            guard let numberOfItems = collectionView?.numberOfItems(inSection: section),
                numberOfItems > 0,
                let firstItem = layoutAttributesForItem(at: indexPath),
                let lastItem = layoutAttributesForItem(at: IndexPath(item: numberOfItems - 1, section: section)) else {
                    continue
            }
            
            var inset = self.sectionInset
            if let delegateInset = delegate.collectionView?(self.collectionView!, layout: self, insetForSectionAt: section) {
                inset = delegateInset
            }
            
            var sectionFrame = firstItem.frame.union(lastItem.frame)
            sectionFrame.origin.x = inset.left
            sectionFrame.origin.y -= inset.top
            
            let headLayout = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath)
            let footLayout = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: indexPath)
            
            if self.scrollDirection == .horizontal {
                sectionFrame.origin.y -= headLayout?.frame.height ?? 0
                sectionFrame.size.width += inset.left + inset.right
                sectionFrame.size.height = (collectionView?.frame.height ?? 0) + (headLayout?.frame.height ?? 0) + (footLayout?.frame.height ?? 0)
            } else {
                sectionFrame.origin.y -= headLayout?.frame.height ?? 0
                sectionFrame.size.width = collectionView?.frame.width ?? 0
                sectionFrame.size.height = sectionFrame.size.height + inset.top + inset.bottom + (headLayout?.frame.height ?? 0) + (footLayout?.frame.height ?? 0)
            }
            
            let attr = UCollectionViewLayoutAttributes(forDecorationViewOfKind: SectionBackground, with: IndexPath(item: 0, section: section))
            attr.frame = sectionFrame
            attr.zIndex = -1
            attr.backgroundColor = delegate.collectionView(self.collectionView!, layout: self, backgroundColorForSectionAt: section)
            
            self.decorationViewAttrs.append(attr)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attrs = super.layoutAttributesForElements(in: rect)
        attrs?.append(contentsOf: decorationViewAttrs.filter {
            return rect.intersects($0.frame)
        })
        return attrs
    }
    
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == SectionBackground {
            return decorationViewAttrs[indexPath.section]
        }
        return super.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath)
    }
}
