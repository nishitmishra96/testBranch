//
//  BaseTableViewDataSource.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 28/11/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.
//

import Foundation
import UIKit
import PagingTableView


class BaseTableViewDataSource:NSObject, UITableViewDataSource,UITableViewDelegate{
    
//    var postList = PostList()
    var delegate : DataForBoard?
    var userId:String?
    var completePosts = [CompletePost]()
    var reuseIdentifier : String?
    
    
    init(userId:String) {
        self.userId = userId
//        postList.posts = []
        completePosts = []
    }
    
    func getPostsWith(for tableView:PagingTableView? = nil, pageNumber:Int){
    }
    func getCommentForPost(){
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return postList.posts?.count ?? 0
        return /completePosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func userLikedOn(postId:Int,handler:@escaping (Int)->()){
        PostsRestManager.shared.userLikedThePost(postId: "\(postId)", userId: self.userId ?? "\(0)") { (statusCode) in
            if statusCode == 204{
                handler(statusCode)
            }else{
                handler(-1000)
            }
        }
    }
    func userUnlikedLiked(postId:Int,handler:@escaping (Int)->()){
        PostsRestManager.shared.userUnlikedThePost(postId: "\(postId)", userId: self.userId ?? "\(0)") { (statusCode) in
            if statusCode == 204{
                handler(statusCode)
            }else{
                handler(-1000)
            }
        }
    }
    
    func userCommentedOn(postId:Int){
        PostsRestManager.shared.userCommentedOnAPost(userId: self.userId ?? "\(0)", postId: "\(postId)") { (statusCode) in
        }
    }
    func getObjectOfCompletePostWith(post: Post)->CompletePost?{
        let requiredCompletePost = self.completePosts.filter { (completePost) -> Bool in
            return post.postId == completePost.post?.postId
        }
        return requiredCompletePost.first
    }
    
}
extension BaseTableViewDataSource: PagingTableViewDelegate{
    
func paginate(_ tableView: PagingTableView, to page: Int) {
    
}
    
}

