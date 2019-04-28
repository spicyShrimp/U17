//
//  UHairPowder.swift
//  U17
//
//  Created by charles on 2017/11/6.
//  Copyright © 2017年 None. All rights reserved.
//

import Foundation
import UIKit

open class UHairPowder {
    public static let instance = UHairPowder()
    
    private class HairPowderView: UIView {
        static let cornerRadius: CGFloat = 40
        static let cornerY: CGFloat = 35
        override func draw(_ rect: CGRect)
        {
            let width = frame.width > frame.height ? frame.height : frame.width
            
            let rectPath = UIBezierPath()
            rectPath.move(to: CGPoint(x:0, y:0))
            rectPath.addLine(to: CGPoint(x: width, y: 0))
            rectPath.addLine(to: CGPoint(x: width, y: HairPowderView.cornerY))
            rectPath.addLine(to: CGPoint(x: 0, y: HairPowderView.cornerY))
            rectPath.close()
            rectPath.fill()

            let leftCornerPath = UIBezierPath()
            leftCornerPath.move(to: CGPoint(x: 0, y: HairPowderView.cornerY + HairPowderView.cornerRadius))
            leftCornerPath.addLine(to: CGPoint(x: 0, y: HairPowderView.cornerY))
            leftCornerPath.addLine(to: CGPoint(x: HairPowderView.cornerRadius, y: HairPowderView.cornerY))
            leftCornerPath.addQuadCurve(to:  CGPoint(x: 0, y: HairPowderView.cornerY+HairPowderView.cornerRadius), controlPoint: CGPoint(x: 0, y: HairPowderView.cornerY))
            leftCornerPath.close()
            leftCornerPath.fill()
            
            let rightCornerPath = UIBezierPath()
            rightCornerPath.move(to: CGPoint(x: width, y: HairPowderView.cornerY+HairPowderView.cornerRadius))
            rightCornerPath.addLine(to: CGPoint(x: width, y: HairPowderView.cornerY))
            rightCornerPath.addLine(to: CGPoint(x: width-HairPowderView.cornerRadius, y: HairPowderView.cornerY))
            rightCornerPath.addQuadCurve(to:  CGPoint(x: width, y: 35+HairPowderView.cornerRadius), controlPoint: CGPoint(x: width, y: HairPowderView.cornerY))
            rightCornerPath.close()
            rightCornerPath.fill()
        }
    }
    
    
    private var statusWindow: UIWindow = {
        let width = UIApplication.shared.keyWindow?.frame.width ?? 0
        let height = UIApplication.shared.keyWindow?.frame.height ?? 0
        
        let statusWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: width, height: 0))
        statusWindow.windowLevel = UIWindow.Level.statusBar - 1
        
        let hairPowderView = HairPowderView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        hairPowderView.backgroundColor = UIColor.clear
        hairPowderView.clipsToBounds = true
        statusWindow.addSubview(hairPowderView)
        return statusWindow
    }()
    
    public func spread() {
        guard isIphoneX else { return }
        guard let window = UIApplication.shared.keyWindow else { return }
        if #available(iOS 11.0, *) {
            if window.safeAreaInsets.top > 0.0 {
                DispatchQueue.main.async { [weak self] in
                    self?.statusWindow.makeKeyAndVisible()
                    DispatchQueue.main.async {
                        window.makeKey()
                    }
                }
            }
        }
    }
}
