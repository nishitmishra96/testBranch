//
//  tableViewDataSource.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 18/11/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.
//

import Foundation
import UIKit
import PagingTableView
import SDWebImage
import ExpandableLabel

class TableViewDataSource:BaseTableViewDataSource{
    public var uploadingNewPost = false
    override init(userId:String) {
        super.init(userId: userId)
    }
    convenience init(){
        self.init()
    }
    
    override func getPostsWith(for tableView:PagingTableView? = nil, pageNumber:Int){
        tableView?.isLoading = true
        PostsRestManager.shared.getMyPost(userId: self.userId ?? "", pageNumber: pageNumber) { (postList, statusCode) -> (Void) in
            tableView?.refreshControl?.endRefreshing()
            if pageNumber == 0 && /self.completePosts.count > 0{
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
                    self.delegate?.newPostsAppended(oldList: oldList , newList: self.completePosts)
                }
            }
            tableView?.isLoading = false
        }
    }
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if uploadingNewPost {
                return completePosts.count + 1
            }else{
            return completePosts.count
            }
        }
    
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if uploadingNewPost {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UploadProgressCell", for: indexPath) as! UploadProgressCell
                cell.delegate.add(tableView as! PostViewer)
                cell.delegate.add(UploadTaskManager.shared)
            return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! PostTableViewCell
            cell.delegate = (tableView as? UserActivities)
            cell.userId = self.userId
            cell.layoutIfNeeded()
            cell.setData(cellPost: completePosts[indexPath.row])
            return cell
        }


    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !uploadingNewPost{
            PostsRestManager.shared.updatePostViewCount(userId: userId, postId: "\(String(describing: self.completePosts[indexPath.row].post?.postId))") { (statusCode) in
                if statusCode == HttpResponseCodes.NotFound.rawValue{
                    print(statusCode,"For id ",String(describing: self.completePosts[indexPath.row].post?.postId),"and description ",/self.completePosts[indexPath.row].post?.content?.descriptionField)
                    (cell as! PostTableViewCell).viewCount.text = "\(/self.completePosts[indexPath.row].post?.viewCount+1)"
                }
            }
        }

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
//    func cellHeight(indexPath:IndexPath)-> CGFloat{
//        let height = /self.completePosts[indexPath.row].descriptionText?.estimatedLabelHeight(text: /self.completePosts[indexPath.row].descriptionText, width: UIScreen.main.bounds.width - 8, font: UIFont.systemFont(ofSize: 14.0))
//        return (152 + /height + (UIScreen.main.bounds.width - 8))
//    }
}


extension TableViewDataSource{
    public override func paginate(_ tableView: PagingTableView, to page: Int) {
        self.getPostsWith(for: tableView, pageNumber: page)
    }
}
