//
//  CommentTableViewDataSource.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 04/12/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.
//

import Foundation
import UIKit
import PagingTableView
class CommentTableViewDataSource:BaseTableViewDataSource{
    var postId:String?
    var allComments : [CompleteComment]?
    convenience init(userId:String,postId:String,comments:[CompleteComment]?){
        self.init(userId:userId)
        self.postId = postId
        self.allComments = comments
        self.allComments = []
    }
    deinit {
        self.postId = nil
        self.allComments?.removeAll()
    }
    override func getCommentForPost(tableView: PagingTableView? = nil, to pageNumber: Int) {
        tableView?.isLoading = true
        PostsRestManager.shared.getCommentsforPostId(userId: /self.userId, postId: /self.postId, pageNumber: pageNumber) { (commentList, statusCode) in
                tableView?.refreshControl?.endRefreshing()
            if pageNumber == 0 && /self.allComments?.count > 0{
                    self.allComments?.removeAll()
                    tableView?.reloadData()
                    tableView?.reset()
                }
                if statusCode == 200{
                    if let listData = commentList{
                        let oldList = self.allComments
                        for comment in listData.commentList ?? []{
                        self.allComments?.append(CompleteComment(comment: comment))
                        }
                        self.delegate?.newCommentAppended(oldList: oldList ?? [] , newList: self.allComments ?? [])
                    }
                }
                tableView?.isLoading = false
            if /self.allComments?.count > 0{
                tableView?.isHidden = false
            }else{
                tableView?.isHidden = true
            }
            }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return /self.allComments?.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentViewCell") as! CommentViewCell
        cell.delegate = (tableView as? UserActivities)
        cell.layoutIfNeeded()
        cell.setData(comment: self.allComments?[indexPath.row],postId:/self.postId,userId:/self.userId)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return self.getCellHeight(completeComment: allComments?[indexPath.row])
        return UITableView.automaticDimension
    }
//    func getCellHeight(completeComment:CompleteComment?) -> CGFloat{
//        let height = /completeComment?.comment?.comment?.estimatedLabelHeight(text: /completeComment?.comment?.comment, width: (UIScreen.main.bounds.width - 112), font: .systemFont(ofSize: 14.0, weight: .regular))
//        return 42 + height + 35
//    }
}

extension CommentTableViewDataSource{
    override func paginate(_ tableView: PagingTableView, to page: Int) {
        self.getCommentForPost(tableView: tableView, to: page)
    }
}
