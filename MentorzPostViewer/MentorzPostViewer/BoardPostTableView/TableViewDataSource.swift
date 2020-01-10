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
import LinkPreviewKit


class TableViewDataSource:NSObject, UITableViewDataSource,UITableViewDelegate{
    public var uploadingNewPost = false
        var delegate : DataForBoard?
        var userId:String?
        var completePosts = [CompletePost]()
        var completePostsWithFilter = [CompletePost]()
        init(userId:String) {
            self.userId = userId
    //        postList.posts = []
            completePosts = []
        }
    convenience override init(){
        self.init()
        
    }
    var filterPostString:String?{
        didSet{
            if /filterPostString == ""{
                self.completePostsWithFilter = completePosts
            }else{
            self.completePostsWithFilter = completePosts.filter({ (post) -> Bool in
                return /post.post?.content?.descriptionField?.lowercased().contains(/filterPostString?.lowercased()) || /post.post?.name?.lowercased().contains(/filterPostString?.lowercased())  || /post.post?.lastName?.lowercased().contains(/filterPostString?.lowercased())
            })
            }
        }
    }
    func getPostsWith(for tableView:PagingTableView? = nil, pageNumber:Int){
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
                    let oldList = self.completePostsWithFilter
                    for post in listData.posts ?? []{
                        self.completePosts.append(CompletePost(post:post))
                    }
                    self.delegate?.newPostsAppended(oldList: oldList , newList: self.completePostsWithFilter)
                }
            }
            let str = self.filterPostString
            self.filterPostString = str
            tableView?.isLoading = false
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if uploadingNewPost {
                return completePostsWithFilter.count + 1
            }else{
            return completePostsWithFilter.count
            }
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if uploadingNewPost {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UploadProgressCell", for: indexPath) as! UploadProgressCell
                cell.delegate.add(tableView as! PostViewer)
                cell.delegate.add(UploadTaskManager.shared)
            return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! PostTableViewCell
            cell.delegate = (tableView as? UserActivities)
            cell.userId = self.userId
            cell.setData(cellPost: completePostsWithFilter[indexPath.row])
            self.getImagePreview(completePost: completePostsWithFilter[indexPath.row], tableView: tableView, indexPath: indexPath,cell: cell)
            return cell
        }


    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !uploadingNewPost{
            PostsRestManager.shared.updatePostViewCount(userId: userId, postId: "\(String(describing: self.completePosts[indexPath.row].post?.postId))") { (statusCode) in
                if statusCode == HttpResponseCodes.NotFound.rawValue{
                    (cell as! PostTableViewCell).viewCount.text = "\(/self.completePostsWithFilter[indexPath.row].post?.viewCount+1)"
                }else{
                    print("view count not increased")
                }
            }
        }

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func getImagePreview(completePost:CompletePost?,tableView:UITableView,indexPath:IndexPath,cell:UITableViewCell){
        if completePost?.post?.content?.mediaType == "TEXT" && /completePost?.post?.content?.lresId?.count <
2{
        if let firstUrl = self.getFirstUrl(completePost:completePost){
                LKLinkPreviewReader.linkPreview(from: firstUrl.url) { (preview,error) in
                    if preview != nil{
                    if ((preview?.first as! LKLinkPreview).imageURL != nil){
                        completePost?.post?.content?.lresId = (preview?.first as! LKLinkPreview).imageURL?.absoluteString
                        completePost?.post?.content?.hresId = (preview?.first as! LKLinkPreview).imageURL?.absoluteString
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                    }else{

                    }
                }
        }else{

        }
        }
    }
    func getFirstUrl(completePost:CompletePost?)-> NSTextCheckingResult?{
        do{
            let dataDetector = try NSDataDetector.init(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let firstMatch = dataDetector.firstMatch(in: /completePost?.post?.content?.descriptionField, options: [], range: NSRange(location: 0, length: /completePost?.post?.content!.descriptionField?.utf16.count))
            return firstMatch
        }
        catch {
            print("No Links")
        }
        return nil
    }
    func userLikedOn(postId:Int,handler:@escaping (Bool)->()){
        PostsRestManager.shared.userLikedThePost(postId: "\(postId)", userId: self.userId ?? "\(0)") { (done) in
            if done{
                handler(done)
            }else{
                handler(!done)
            }
        }
    }
    func userUnlikedLiked(postId:Int,handler:@escaping (Bool)->()){
        PostsRestManager.shared.userUnlikedThePost(postId: "\(postId)", userId: self.userId ?? "\(0)") { (done) in
            if done{
                handler(done)
            }else{
                handler(!done)
            }
        }
    }
    
    func getObjectOfCompletePostWith(post: Post)->CompletePost?{
        let requiredCompletePost = self.completePostsWithFilter.filter { (completePost) -> Bool in
            return post.postId == completePost.post?.postId
        }
        return requiredCompletePost.first
    }
    
}


extension TableViewDataSource:PagingTableViewDelegate{
    public func paginate(_ tableView: PagingTableView, to page: Int) {
        self.getPostsWith(for: tableView, pageNumber: page)
    }
}
