//
//  UHomeViewController.swift
//  U17
//
//  Created by charles on 2017/10/24.
//  Copyright © 2017年 None. All rights reserved.
//

import UIKit

class UHomeViewController: UPageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configNavigationBar() {
        super.configNavigationBar()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav_search"),
                                                            target: self,
                                                            action: #selector(selectAction))
    }
    
    @objc private func selectAction() {
        navigationController?.pushViewController(USearchViewController(), animated: true)
    }
}
