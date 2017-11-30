//
//  UChapterCCell.swift
//  U17
//
//  Created by charles on 2017/11/22.
//  Copyright © 2017年 None. All rights reserved.
//

import UIKit

class UChapterCCell: UBaseCollectionViewCell {
    lazy var nameLabel: UILabel = {
        let nl = UILabel()
        nl.font = UIFont.systemFont(ofSize: 16)
        return nl
    }()
    
    override func configUI() {
        contentView.backgroundColor = UIColor.white
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        layer.masksToBounds = true
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsetsMake(0, 10, 0, 10)) }
    }
    
    var chapterStatic: ChapterStaticModel? {
        didSet {
            guard let chapterStatic = chapterStatic else { return }
            nameLabel.text = chapterStatic.name
        }
    }
}
