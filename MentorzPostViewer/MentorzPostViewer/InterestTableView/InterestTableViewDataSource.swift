//
//  InterestTableViewDataSource.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 28/11/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.
//

import Foundation
import PagingTableView
class InterestTableViewDataSource:TableViewDataSource{
    var interest : [Int] = []
    func getPostByInterests(userId:String,interest:[Int],pageNumber:Int){
       var queryparams = "?"
       
       for value in interest{
           queryparams = queryparams+"interest=\(value)&"
       }
       PostsRestManager.shared.getPostOnUserInterest(userId: userId, interestString: queryparams, pageNumber: pageNumber) { (postList, statusCode) -> (Void) in
           if let postList = postList{
//               self.postList = postList
            for post in postList.posts ?? []{
                  self.completePosts.append(CompletePost(post:post))
              }
               self.delegate?.reloadTableView()
           }
       }
   }
    
}

extension InterestTableViewDataSource{
    public override func paginate(_ tableView: PagingTableView, to page: Int) {
        self.getPostByInterests(userId: userId ?? "0", interest: self.interest, pageNumber: page)
    }
}
