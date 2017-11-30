//
//  UChapterViewController.swift
//  U17
//
//  Created by charles on 2017/11/15.
//  Copyright © 2017年 None. All rights reserved.
//

import UIKit

class UChapterViewController: UBaseViewController {

    private var isPositive: Bool = true
    
    var detailStatic: DetailStaticModel?
    var detailRealtime: DetailRealtimeModel?

    weak var delegate: UComicViewWillEndDraggingDelegate?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 10, 10, 10)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: floor((screenWidth - 30) / 2), height: 40)
        let cw = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cw.backgroundColor = UIColor.white
        cw.delegate = self
        cw.dataSource = self
        cw.alwaysBounceVertical = true
        cw.register(supplementaryViewType: UChapterCHead.self, ofKind: UICollectionElementKindSectionHeader)
        cw.register(cellType: UChapterCCell.self)
        return cw
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    override func configUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {$0.edges.equalTo(self.view.usnp.edges) }
    }
}

extension UChapterViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.comicWillEndDragging(scrollView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return detailStatic?.chapter_list?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: screenWidth, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let head = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, for: indexPath, viewType: UChapterCHead.self)
        head.model = detailStatic
        head.sortClosure { [weak self] (button) in
            if self?.isPositive == true {
                self?.isPositive = false
                button.setTitle("正序", for: .normal)
            } else {
                self?.isPositive = true
                button.setTitle("倒序", for: .normal)
            }
            self?.collectionView.reloadData()
        }
        return head
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: UChapterCCell.self)
        if isPositive {
            cell.chapterStatic = detailStatic?.chapter_list?[indexPath.row]
        } else {
            cell.chapterStatic = detailStatic?.chapter_list?.reversed()[indexPath.row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = isPositive ? indexPath.row : ((detailStatic?.chapter_list?.count)! - indexPath.row - 1)
        let vc = UReadViewController(detailStatic: detailStatic, selectIndex: index)
        navigationController?.pushViewController(vc, animated: true)
    }
}
