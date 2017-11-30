//
//  URankListViewController.swift
//  U17
//
//  Created by charles on 2017/10/23.
//  Copyright © 2017年 None. All rights reserved.
//

import UIKit

class URankListViewController: UBaseViewController {

    private var rankList = [RankingModel]()
    
    private lazy var tableView: UITableView = {
        let tw = UITableView(frame: .zero, style: .plain)
        tw.backgroundColor = UIColor.background
        tw.tableFooterView = UIView()
        tw.separatorStyle = .none
        tw.delegate = self
        tw.dataSource = self
        tw.separatorStyle = .none
        tw.register(cellType: URankTCell.self)
        tw.uHead = URefreshHeader{ self.loadData() }
        tw.uempty = UEmptyView { self.loadData() }
        return tw
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
    }
    
    @objc private func loadData() {
        ApiLoadingProvider.request(UApi.rankList, model: RankinglistModel.self) { (returnData) in
            self.tableView.uHead.endRefreshing()
            self.tableView.uempty?.allowShow = true
            
            self.rankList = returnData?.rankinglist ?? []
            self.tableView.reloadData()
        }
    }
    
    override func configUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints{ $0.edges.equalTo(self.view.usnp.edges) }
    }
}

extension URankListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: URankTCell.self)
        cell.model = rankList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return screenWidth * 0.4
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = rankList[indexPath.row]
        let vc = UComicListViewController(argCon: model.argCon,
                                          argName: model.argName,
                                          argValue: model.argValue)
        vc.title = "\(model.title!)榜"
        navigationController?.pushViewController(vc, animated: true)
    }
}
