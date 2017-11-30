//
//  UCommentViewController.swift
//  U17
//
//  Created by charles on 2017/11/16.
//  Copyright © 2017年 None. All rights reserved.
//

import UIKit

class UCommentViewController: UBaseViewController {
    
    var detailStatic: DetailStaticModel?
    var commentList: CommentListModel? {
        didSet {
            guard let commentList = commentList?.commentList else { return }
            let viewModelArray = commentList.flatMap { (comment) -> UCommentViewModel? in
                return UCommentViewModel(model: comment)
            }
            listArray.append(contentsOf: viewModelArray)
        }
    }
    
    private var listArray = [UCommentViewModel]()
    
    
    weak var delegate: UComicViewWillEndDraggingDelegate?
    
    private lazy var tableView: UITableView = {
        let tw = UITableView(frame: .zero, style: .plain)
        tw.delegate = self
        tw.dataSource = self
        tw.register(cellType: UCommentTCell.self)
        tw.uFoot = URefreshFooter { self.loadData() }
        return tw
        
    }()
    
    func loadData() {
        ApiProvider.request(UApi.commentList(object_id: detailStatic?.comic?.comic_id ?? 0,
                                             thread_id: detailStatic?.comic?.thread_id ?? 0,
                                             page: commentList?.serverNextPage ?? 0),
                            model: CommentListModel.self) { (returnData) in
                                if returnData?.hasMore == true {
                                    self.tableView.uFoot.endRefreshing()
                                } else {
                                    self.tableView.uFoot.endRefreshingWithNoMoreData()
                                }
                                self.commentList = returnData
                                self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    override func configUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {$0.edges.equalTo(self.view.usnp.edges) }
    }
}

extension UCommentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.comicWillEndDragging(scrollView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return listArray[indexPath.row].height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: UCommentTCell.self)
        cell.viewModel = listArray[indexPath.row]
        return cell
    }
}

