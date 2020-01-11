//
//  BoardPostUITableView.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 11/01/20.
//  Copyright © 2020 Nishit Mishra. All rights reserved.
//

import UIKit

public class BoardPostUITableView: BaseTableView {
    var controller:PostController?
    open override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @objc override func didPullToRefresh(){
        self.refreshControl?.beginRefreshing()
        self.controller?.getPost(forPage: 0)
    }
    public func filterLocalPost(string:String){
        self.controller?.filterPostString = string
        self.reloadData()
    }
    public func setupTableViewForBoardPost(user id:String){
        self.controller = PostController(userid: id, base: self)
    }
    public func setupTableViewForBoardPostBasedOnInterestList(user id:String,interesetList:[Int]){
        self.controller = PostController(userid: id, base: self, interestList: interesetList)
    }
}
