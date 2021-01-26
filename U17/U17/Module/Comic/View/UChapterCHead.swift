//
//  UChapterCHead.swift
//  U17
//
//  Created by charles on 2017/11/23.
//  Copyright © 2017年 None. All rights reserved.
//

import UIKit

typealias UChapterCHeadSortClosure = (_ button: UIButton) -> Void

class UChapterCHead: UBaseCollectionReusableView {
    
    private var sortClosure: UChapterCHeadSortClosure?
    
    private lazy var chapterLabel: UILabel = {
        let vl = UILabel()
        vl.textColor = UIColor.gray
        vl.font = UIFont.systemFont(ofSize: 13)
        return vl
    }()
    
    private lazy var sortButton: UIButton = {
        let sn = UIButton(type: .system)
        sn.setTitle("倒序", for: .normal)
        sn.setTitleColor(UIColor.gray, for: .normal)
        sn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        sn.addTarget(self, action: #selector(sortAction(for:)), for: .touchUpInside)
        return sn
    }()
    
    @objc private func sortAction(for button: UIButton) {
        guard let sortClosure = sortClosure else { return }
        sortClosure(button)
    }
    
    func sortClosure(_ closure: @escaping UChapterCHeadSortClosure) {
        sortClosure = closure
    }
    
    override func configUI() {
        
        addSubview(sortButton)
        sortButton.snp.makeConstraints {
            $0.right.equalToSuperview()
            $0.right.top.bottom.equalToSuperview()
            $0.width.equalTo(44)
        }
        
        addSubview(chapterLabel)
        chapterLabel.snp.makeConstraints {
            $0.left.equalTo(10)
            $0.top.bottom.equalToSuperview()
            $0.right.equalTo(sortButton.snp.left).offset(-10)
        }
    }
    
    var model: DetailStaticModel? {
        didSet {
            guard let model = model else { return }
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd"
            chapterLabel.text = "目录 \(format.string(from: Date(timeIntervalSince1970: model.comic?.last_update_time ?? 0))) 更新 \(model.chapter_list?.last?.name ?? "")"
        }
    }
}
