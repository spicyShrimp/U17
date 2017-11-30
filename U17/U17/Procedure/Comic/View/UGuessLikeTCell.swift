//
//  UGuessLikeTCell.swift
//  U17
//
//  Created by charles on 2017/11/27.
//  Copyright © 2017年 None. All rights reserved.
//

import UIKit

typealias UGuessLikeTCellDidSelectClosure = (_ comic: ComicModel) -> Void

class UGuessLikeTCell: UBaseTableViewCell {
    
    private var didSelectClosure: UGuessLikeTCellDidSelectClosure?
    
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 0, 10)
        layout.scrollDirection = .horizontal
        let cw = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cw.backgroundColor = self.contentView.backgroundColor
        cw.delegate = self
        cw.dataSource = self
        cw.isScrollEnabled = false
        cw.register(cellType: UComicCCell.self)
        return cw
    }()

    override func configUI() {
        let titileLabel = UILabel().then{
            $0.text = "猜你喜欢"
        }
        contentView.addSubview(titileLabel)
        titileLabel.snp.makeConstraints{
            $0.top.left.right.equalToSuperview().inset(UIEdgeInsetsMake(15, 15, 15, 15))
            $0.height.equalTo(20)
        }
        
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(titileLabel.snp.bottom).offset(5)
            $0.left.bottom.right.equalToSuperview()
        }
    }
    
    var model: GuessLikeModel? {
        didSet {
            self.collectionView.reloadData()
        }
    }
}


extension UGuessLikeTCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model?.comics?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor((collectionView.frame.width - 50) / 4)
        let height = collectionView.frame.height - 10
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: UComicCCell.self)
        cell.style = .withTitle
        cell.model = model?.comics?[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let comic = model?.comics?[indexPath.row],
        let didSelectClosure = didSelectClosure else { return }
        didSelectClosure(comic)
    }
    
    func didSelectClosure(_ closure: UGuessLikeTCellDidSelectClosure?) {
        didSelectClosure = closure
    }
}
