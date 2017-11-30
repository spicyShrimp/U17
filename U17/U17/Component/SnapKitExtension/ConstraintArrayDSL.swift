//
//  ConstraintArrayDSL.swift
//  U17
//
//  Created by charles on 2017/8/27.
//  Copyright © 2017年 None. All rights reserved.
//

import SnapKit

public struct ConstraintArrayDSL {
    @discardableResult
    public func prepareConstraints(_ closure: (_ make: ConstraintMaker) -> Void) -> [Constraint] {
        var constraints = Array<Constraint>()
        for view in self.array {
            constraints.append(contentsOf: view.snp.prepareConstraints(closure))
        }
        return constraints
    }
    
    public func makeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        for view in self.array {
            view.snp.makeConstraints(closure)
        }
    }
    
    public func remakeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        for view in self.array {
            view.snp.remakeConstraints(closure)
        }
    }
    
    public func updateConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        for view in self.array {
            view.snp.updateConstraints(closure)
        }
    }
    
    public func removeConstraints() {
        for view in self.array {
            view.snp.removeConstraints()
        }
    }
    
    /// distribute with fixed spacing
    ///
    /// - Parameters:
    ///   - axisType: which axis to distribute items along
    ///   - fixedSpacing: the spacing between each item
    ///   - leadSpacing: the spacing before the first item and the container
    ///   - tailSpacing: the spacing after the last item and the container
    public func distributeViewsAlong(axisType:UILayoutConstraintAxis,
                                     fixedSpacing:CGFloat,
                                     leadSpacing:CGFloat = 0,
                                     tailSpacing:CGFloat = 0) {
        
        guard self.array.count > 1, let tempSuperView = commonSuperviewOfViews() else {
            return
        }
        
        if axisType == .horizontal {
            var prev : ConstraintView?
            for (i, v) in self.array.enumerated() {
                v.snp.makeConstraints({ (make) in
                    if prev != nil {
                        make.width.equalTo(prev!)
                        make.left.equalTo((prev?.snp.right)!).offset(fixedSpacing)
                        if (i == self.array.count - 1) {//last one
                            make.right.equalTo(tempSuperView).offset(-tailSpacing);
                        }
                    }else {
                        make.left.equalTo(tempSuperView).offset(leadSpacing);
                    }
                })
                prev = v;
            }
        }else {
            var prev : ConstraintView?
            for (i, v) in self.array.enumerated() {
                v.snp.makeConstraints({ (make) in
                    if prev != nil {
                        make.height.equalTo(prev!)
                        make.top.equalTo((prev?.snp.bottom)!).offset(fixedSpacing)
                        if (i == self.array.count - 1) {//last one
                            make.bottom.equalTo(tempSuperView).offset(-tailSpacing);
                        }
                    }else {
                        make.top.equalTo(tempSuperView).offset(leadSpacing);
                    }
                })
                prev = v;
            }
        }
    }
    
    /// distribute with fixed item size
    ///
    /// - Parameters:
    ///   - axisType: which axis to distribute items along
    ///   - fixedItemLength: the fixed length of each item
    ///   - leadSpacing: the spacing before the first item and the container
    ///   - tailSpacing: the spacing after the last item and the container
    public func distributeViewsAlong(axisType:UILayoutConstraintAxis,
                                     fixedItemLength:CGFloat,
                                     leadSpacing:CGFloat = 0,
                                     tailSpacing:CGFloat = 0) {
        
        guard self.array.count > 1, let tempSuperView = commonSuperviewOfViews() else {
            return
        }
        
        if axisType == .horizontal {
            var prev : ConstraintView?
            for (i, v) in self.array.enumerated() {
                v.snp.makeConstraints({ (make) in
                    make.width.equalTo(fixedItemLength)
                    if prev != nil {
                        if (i == self.array.count - 1) {//last one
                            make.right.equalTo(tempSuperView).offset(-tailSpacing);
                        }else {
                            let offset = (CGFloat(1) - (CGFloat(i) / CGFloat(self.array.count - 1))) *
                                (fixedItemLength + leadSpacing) - CGFloat(i) *
                                tailSpacing /
                                CGFloat(self.array.count - 1)
                            make.right
                                .equalTo(tempSuperView)
                                .multipliedBy(CGFloat(i) / CGFloat(self.array.count - 1))
                                .offset(offset)
                        }
                    }else {
                        make.left.equalTo(tempSuperView).offset(leadSpacing);
                    }
                })
                prev = v;
            }
        }else {
            var prev : ConstraintView?
            for (i, v) in self.array.enumerated() {
                v.snp.makeConstraints({ (make) in
                    make.height.equalTo(fixedItemLength)
                    if prev != nil {
                        if (i == self.array.count - 1) {//last one
                            make.bottom.equalTo(tempSuperView).offset(-tailSpacing);
                        }else {
                            let offset = (CGFloat(1) - (CGFloat(i) / CGFloat(self.array.count - 1))) *
                                    (fixedItemLength + leadSpacing) - CGFloat(i) *
                                    tailSpacing /
                                    CGFloat(self.array.count - 1)
                            
                            make.bottom
                                .equalTo(tempSuperView)
                                .multipliedBy(CGFloat(i) / CGFloat(self.array.count-1))
                                .offset(offset)
                        }
                    }else {
                        make.top.equalTo(tempSuperView).offset(leadSpacing);
                    }
                })
                prev = v;
            }
        }
    }
    
    public func distributeSudokuViews(fixedItemWidth: CGFloat,
                                      fixedItemHeight: CGFloat,
                                      warpCount: Int,
                                      edgeInset: UIEdgeInsets = UIEdgeInsets.zero) {
        
        guard self.array.count > 1, warpCount >= 1, let tempSuperView = commonSuperviewOfViews() else {
            return
        }
        
        let rowCount = self.array.count % warpCount == 0 ? self.array.count / warpCount : self.array.count / warpCount + 1;
        let columnCount = warpCount
        
        for (i,v) in self.array.enumerated() {
            
            let currentRow = i / warpCount
            let currentColumn = i % warpCount
            
            v.snp.makeConstraints({ (make) in
                make.width.equalTo(fixedItemWidth)
                make.height.equalTo(fixedItemHeight)
                if currentRow == 0 {//fisrt row
                    make.top.equalTo(tempSuperView).offset(edgeInset.top)
                }
                if currentRow == rowCount - 1 {//last row
                    make.bottom.equalTo(tempSuperView).offset(-edgeInset.bottom)
                }
                
                if currentRow != 0 && currentRow != rowCount - 1 {//other row
                    let offset = (CGFloat(1) - CGFloat(currentRow) / CGFloat(rowCount - 1)) * (fixedItemHeight + edgeInset.top) - CGFloat(currentRow) * edgeInset.bottom / CGFloat(rowCount - 1)
                    make.bottom
                        .equalTo(tempSuperView)
                        .multipliedBy(CGFloat(currentRow) / CGFloat(rowCount - 1))
                        .offset(offset);
                }
                
                if currentColumn == 0 {//first col
                    make.left.equalTo(tempSuperView).offset(edgeInset.left)
                }
                if currentColumn == columnCount - 1 {//last col
                    make.right.equalTo(tempSuperView).offset(-edgeInset.right)
                }
                
                if currentColumn != 0 && currentColumn != columnCount - 1 {//other col
                    let offset = (CGFloat(1) - CGFloat(currentColumn) / CGFloat(columnCount - 1)) * (fixedItemWidth + edgeInset.left) - CGFloat(currentColumn) * edgeInset.right / CGFloat(columnCount - 1)
                    make.right
                        .equalTo(tempSuperView)
                        .multipliedBy(CGFloat(currentColumn) / CGFloat(columnCount - 1))
                        .offset(offset);
                }
            })
        }
    }
    
    public func distributeSudokuViews(fixedLineSpacing: CGFloat,
                                      fixedInteritemSpacing: CGFloat,
                                      warpCount: Int,
                                      edgeInset: UIEdgeInsets = UIEdgeInsets.zero) {
        
        guard self.array.count > 1, warpCount >= 1, let tempSuperView = commonSuperviewOfViews() else {
            return
        }
        
        let columnCount = warpCount
        let rowCount = self.array.count % warpCount == 0 ? self.array.count / warpCount : self.array.count / warpCount + 1;
        
        var prev : ConstraintView?
        
        for (i,v) in self.array.enumerated() {
            
            let currentRow = i / warpCount
            let currentColumn = i % warpCount
            
            v.snp.makeConstraints({ (make) in
                if prev != nil {
                    make.width.height.equalTo(prev!)
                }
                if currentRow == 0 {//fisrt row
                    make.top.equalTo(tempSuperView).offset(edgeInset.top)
                }
                if currentRow == rowCount - 1 {//last row
                    if currentRow != 0 && i - columnCount >= 0 {
                        make.top.equalTo(self.array[i-columnCount].snp.bottom).offset(fixedLineSpacing)
                    }
                    make.bottom.equalTo(tempSuperView).offset(-edgeInset.bottom)
                }
                
                if currentRow != 0 && currentRow != rowCount - 1 {//other row
                    make.top.equalTo(self.array[i-columnCount].snp.bottom).offset(fixedLineSpacing);
                }
                
                if currentColumn == 0 {//first col
                    make.left.equalTo(tempSuperView).offset(edgeInset.left)
                }
                if currentColumn == warpCount - 1 {//last col
                    if currentColumn != 0 {
                        make.left.equalTo(prev!.snp.right).offset(fixedInteritemSpacing)
                    }
                    make.right.equalTo(tempSuperView).offset(-edgeInset.right)
                }
                
                if currentColumn != 0 && currentColumn != warpCount - 1 {//other col
                    make.left.equalTo(prev!.snp.right).offset(fixedInteritemSpacing);
                }
            })
            prev = v
        }
    }
    
    
    
    
    
    public var target: AnyObject? {
        return self.array as AnyObject
    }
    
    internal let array: Array<ConstraintView>
    
    internal init(array: Array<ConstraintView>) {
        self.array = array
        
    }
    
}

private extension ConstraintArrayDSL {
    func commonSuperviewOfViews() -> ConstraintView? {
        var commonSuperview : ConstraintView?
        var previousView : ConstraintView?
        
        for view in self.array {
            if previousView != nil {
                commonSuperview = view.closestCommonSuperview(commonSuperview)
            }else {
                commonSuperview = view
            }
            previousView = view
        }
        
        return commonSuperview
    }
}

private extension ConstraintView {
    func closestCommonSuperview(_ view : ConstraintView?) -> ConstraintView? {
        var closestCommonSuperview: ConstraintView?
        var secondViewSuperview: ConstraintView? = view
        while closestCommonSuperview == nil && secondViewSuperview != nil {
            var firstViewSuperview: ConstraintView? = self
            while closestCommonSuperview == nil && firstViewSuperview != nil {
                if secondViewSuperview == firstViewSuperview {
                    closestCommonSuperview = secondViewSuperview
                }
                firstViewSuperview = firstViewSuperview?.superview
            }
            secondViewSuperview = secondViewSuperview?.superview
        }
        return closestCommonSuperview
        
    }
}
