//
//  UReadBottomBar.swift
//  U17
//
//  Created by Charles on 2017/11/26.
//  Copyright © 2017年 None. All rights reserved.
//

import UIKit

class UReadBottomBar: UIView {
    
    lazy var menuSlider: UISlider = {
        let mr = UISlider()
        mr.thumbTintColor = UIColor.theme
        mr.minimumTrackTintColor = UIColor.theme
        mr.isContinuous = false
        return mr
    }()
    
    lazy var deviceDirectionButton: UIButton = {
        let dn = UIButton(type: .system)
        dn.setImage(UIImage(named: "readerMenu_changeScreen_horizontal")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return dn
    }()
    
    lazy var lightButton: UIButton = {
        let ln = UIButton(type: .system)
        ln.setImage(UIImage(named: "readerMenu_luminance")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return ln
    }()
    
    lazy var chapterButton: UIButton = {
        let cn = UIButton(type: .system)
        cn.setImage(UIImage(named: "readerMenu_catalog")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return cn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        addSubview(menuSlider)
        menuSlider.snp.makeConstraints {
            $0.left.right.top.equalToSuperview().inset(UIEdgeInsetsMake(10, 40, 10, 40))
            $0.height.equalTo(30)
            
        }
        
        addSubview(deviceDirectionButton)
        addSubview(lightButton)
        addSubview(chapterButton)
        
        let buttonArray = [deviceDirectionButton, lightButton, chapterButton]
        buttonArray.snp.distributeViewsAlong(axisType: .horizontal, fixedItemLength: 60, leadSpacing: 40, tailSpacing: 40)
        buttonArray.snp.makeConstraints {
            $0.top.equalTo(menuSlider.snp.bottom).offset(10)
            $0.bottom.equalToSuperview()
        }
    }
    

}
