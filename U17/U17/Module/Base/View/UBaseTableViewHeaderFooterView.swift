//
//  UBaseTableViewHeaderFooterView.swift
//  U17
//
//  Created by Charles on 2017/11/10.
//  Copyright © 2017年 None. All rights reserved.
//

import UIKit
import Reusable

class UBaseTableViewHeaderFooterView: UITableViewHeaderFooterView, Reusable {

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func configUI() {}

}
