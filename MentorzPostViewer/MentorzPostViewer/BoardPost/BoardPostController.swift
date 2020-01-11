//
//  BoardPostController.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 11/01/20.
//  Copyright © 2020 Nishit Mishra. All rights reserved.
//

import UIKit
import Foundation
import PagingTableView
class PostController: NSObject,UITableViewDataSource,UITableViewDelegate,PagingTableViewDelegate {
    private var userID:String
    private var tableView:BaseTableView
    private var boardPostOriginal:[CompletePost] = []
    private var postToShowOnUI:[CompletePost] = []
    
    var filterPostString:String?{
        didSet{
            if /filterPostString == ""{
                self.postToShowOnUI = boardPostOriginal
            }else{
                self.postToShowOnUI = boardPostOriginal.filter({ (post) -> Bool in
                    return /post.post?.content?.postText?.lowercased().contains(/filterPostString?.lowercased()) || /post.post?.name?.lowercased().contains(/filterPostString?.lowercased())  || /post.post?.lastName?.lowercased().contains(/filterPostString?.lowercased())
                })
            }
        }
    }
    
    init(userid:String,base tableView:BaseTableView) {
        self.userID = userid
        self.tableView = tableView
        super.init()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        return self.postToShowOnUI.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "UploadProgressCell", for: indexPath) as! UploadProgressCell
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! PostTableViewCell
        cell.cellDelegate = self
        cell.indexPath =  indexPath
        cell.setData(cellPost: postToShowOnUI[indexPath.row])
        return cell
    }
    public func paginate(_ tableView: PagingTableView, to page: Int) {
        self.getPost(forPage: page)
    }
}
extension PostController{
    func getPost(forPage:Int){
        tableView.isLoading = true
        PostsRestManager.shared.getPosts(userId: self.userID , pageNumber: forPage) { (postList, statusCode) -> (Void) in
            self.tableView.refreshControl?.endRefreshing()
            if forPage == 0 && /self.boardPostOriginal.count > 0{
                self.boardPostOriginal.removeAll()
                self.tableView.reloadData()
                self.tableView.reset()
            }
            if statusCode == 200{
                if let listData = postList{
                    let oldList = self.postToShowOnUI
                    for post in listData.posts ?? []{
                        self.boardPostOriginal.append(CompletePost(post:post))
                    }
                    self.tableView.updateTableViewForNewAppendedData(oldList: oldList.count, newList: self.postToShowOnUI.count)
                }
            }
            let str = self.filterPostString
            self.filterPostString = str
            self.tableView.isLoading = false
        }
        
    }
}
extension PostController:PostTableViewCellDelegate{
    func shouldRemoveCell(indexPath: IndexPath) {
        self.tableView.deleteRows(at: [indexPath], with: .left)
    }
    
    func reloadTableView(indexPath: IndexPath) {
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
