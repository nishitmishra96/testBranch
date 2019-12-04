//
//  ProfilePostViewerDataSource.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 28/11/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.
//

import Foundation
import PagingTableView

class ProfilePostViewerDataSource:TableViewDataSource{
    var arrayOfInterests : [Int] = []

    override func getPostsWith(for tableView: PagingTableView? = nil, pageNumber: Int?) {
        tableView?.isLoading = true
        PostsRestManager.shared.getMyPost(userId: self.userId ?? "0",pageNumber:pageNumber ?? 0) { (postList, statusCode) -> (Void) in
            tableView?.refreshControl?.endRefreshing()
            if pageNumber == 0 && self.completePosts.count > 0{
                self.completePosts.removeAll()
                tableView?.reloadData()
                tableView?.reset()
            }
            if statusCode == 200{
                if let listData = postList{
                    let oldList = self.completePosts
                    for post in listData.posts ?? []{
                        self.completePosts.append(CompletePost(post:post))
                    }
                    self.delegate?.newPostsAppended(oldList: oldList ?? [], newList: self.completePosts ?? [])
                }
            }
            tableView?.isLoading = false
        }
    }

}

