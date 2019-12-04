//
//  Testing.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 12/11/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.
//

import UIKit
import SVProgressHUD
import PagingTableView
import ExpandableLabel
open class PostViewer:BaseTableView {
    var dataSourceTableView : BaseTableViewDataSource?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setUp()
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @objc override func didPullToRefresh(){
        self.refreshControl?.beginRefreshing()
        dataSourceTableView?.getPostsWith(for: self, pageNumber: 0)
    }
    
    
    public func getPostsFor(userId: String){
        self.dataSourceTableView = TableViewDataSource(userId: userId)
        dataSourceTableView?.delegate = self
        pagingDelegate = dataSourceTableView
        dataSourceTableView?.reuseIdentifier = "PostTableViewCell"
        self.dataSource = dataSourceTableView
        self.delegate = dataSourceTableView
    }
}

extension PostViewer:DataForBoard{
    func newPostsAppended(oldList: [CompletePost], newList: [CompletePost]) {
        self.beginUpdates()
        var indexes = [IndexPath]()
        for count in 0..<(newList.count - oldList.count){
            let indexpath = IndexPath(row: (oldList.count - 1) + count, section: 0)
            indexes.append(indexpath)
        }
        self.insertRows(at: indexes, with: .none)
        self.endUpdates()
    }
    
   @objc func reloadTableView() {
        self.reloadData()
    }
    
    func removeCell(){
        
    }
}

extension PostViewer: UserActivities{
    func userReportedAPostWith(post:Post, type: String) {
        PostsRestManager.shared.reportPost(userId: /self.dataSourceTableView?.userId, postId: "\(/post.postId)", type: type){ (statusCode) in
            if statusCode == HttpResponseCodes.NoContent.rawValue{
                let requiredCompletePost = self.dataSourceTableView?.getObjectOfCompletePostWith(post: post)
                if let completePost = requiredCompletePost{
                    let index = self.dataSourceTableView?.completePosts.firstIndex(of: completePost)
                    self.dataSourceTableView?.completePosts.remove(at: index!)
                    let indexPath = IndexPath(row: /index, section: 0)
                    self.beginUpdates()
                    self.deleteRows(at: [indexPath], with: .automatic)
                    self.endUpdates()
                }else{
                    SVProgressHUD.showError(withStatus: "Something Went Wrong \(statusCode!)")
                }
            }else{
                SVProgressHUD.showError(withStatus: "Something Went Wrong \(statusCode!)")
            }

        }
    }
    
    func userUnLiked(postId: Int, handler: @escaping ((Int) -> ())) {
        self.dataSourceTableView?.userUnlikedLiked(postId: postId){ (statusCode) in
            if statusCode == 204{
                handler(statusCode)
            }
            else{
                handler(-1000)
            }
        }
    }
    
    func userLiked(postId: Int, handler: @escaping ((Int) -> ())) {
        self.dataSourceTableView?.userLikedOn(postId: postId){ (statusCode) in
            if statusCode == 204{
                handler(statusCode)
            }
            else{
                handler(-1000)
            }
        }
    }
    
    func userCommented(postId: Int) {
//        self.userCommented(postId: postId)
    }
}



extension PostViewer : ExpandableLabelDelegate{
    public func willExpandLabel(_ label: ExpandableLabel) {
          self.beginUpdates()
      }
      
    public func didExpandLabel(_ label: ExpandableLabel) {
          let point = label.convert(CGPoint.zero, to: self)
          if let indexPath = self.indexPathForRow(at: point) as IndexPath? {
              DispatchQueue.main.async { [weak self] in
                  self?.scrollToRow(at: indexPath, at: .top, animated: true)
              }
          }
          self.endUpdates()
      }
      
    public func willCollapseLabel(_ label: ExpandableLabel) {
          self.beginUpdates()
      }
      
    public func didCollapseLabel(_ label: ExpandableLabel) {
          let point = label.convert(CGPoint.zero, to: self)
          if let indexPath = self.indexPathForRow(at: point) as IndexPath? {
              DispatchQueue.main.async { [weak self] in
                  self?.scrollToRow(at: indexPath, at: .top, animated: true)
              }
          }
          self.endUpdates()
      }
    
}
