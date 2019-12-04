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
    
    override init(userId:String) {
        super.init(userId: userId)
    }
    convenience init(){
        self.init()
    }
    
    override func getPostsWith(for tableView:PagingTableView? = nil, pageNumber:Int){
        tableView?.isLoading = true
        PostsRestManager.shared.getPosts(userId: self.userId ?? "", pageNumber: pageNumber) { (postList, statusCode) -> (Void) in
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
            return completePosts.count 
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: /self.reuseIdentifier, for: indexPath) as! PostTableViewCell
            cell.delegate = (tableView as? UserActivities)
//            cell.postText.delegate = tableView as? ExpandableLabelDelegate
            cell.setData(cellPost: completePosts[indexPath.row])
            return cell
        }


    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        PostsRestManager.shared.updatePostViewCount(userId: userId, postId: "\(String(describing: self.completePosts[indexPath.row].post?.postId))") { (statusCode) in
            if statusCode == HttpResponseCodes.NotFound.rawValue{
                print(statusCode,"For id ",String(describing: self.completePosts[indexPath.row].post?.postId),"and description ",/self.completePosts[indexPath.row].post?.content?.descriptionField)
                (cell as! PostTableViewCell).viewCount.text = "\(/self.completePosts[indexPath.row].post?.viewCount+1)"
            }
        }
    }
}

extension TableViewDataSource{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }

}

extension TableViewDataSource{
    public override func paginate(_ tableView: PagingTableView, to page: Int) {
        self.getPostsWith(for: tableView, pageNumber: page)
    }
}
