//
//  RestDataSource.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 11/01/20.
//  Copyright © 2020 Nishit Mishra. All rights reserved.
//

import Foundation
protocol RestDataSource {
    func getPost(forPage:Int,handler: @escaping (([CompletePost]?,Int)->()) )
}
class profileDataSource:RestDataSource{
    private var userid:String
    init(user id:String){
        self.userid = id
    }
    func getPost(forPage: Int, handler: @escaping (([CompletePost]?, Int) -> ())) {
        PostsRestManager.shared.getMyPost(userId: /self.userid ,pageNumber:forPage) { (postList, statusCode) -> (Void) in
        var responseList = [CompletePost]()
        for post in postList?.posts ?? []{
            let completepost = CompletePost(post: post)
            responseList.append(completepost)
        }
        handler(responseList,statusCode)
        }
    }
}
class BoardPost:RestDataSource{
    private var userid:String?
    init(user id:String) {
        self.userid = id
    }
    func getPost(forPage: Int,handler: @escaping (([CompletePost]?,Int)->()) ) {
        PostsRestManager.shared.getPosts(userId: /self.userid , pageNumber: forPage) { (postList, statusCode) -> (Void) in
            var responseList = [CompletePost]()
            for post in postList?.posts ?? []{
                let completepost = CompletePost(post: post)
                responseList.append(completepost)
            }
            handler(responseList,statusCode)
        }
    }
}
class InterestDataSource:RestDataSource{
    private var userid:String?
    private var interestList:[Int]
    init(user id:String,InterestList:[Int]) {
        self.interestList = InterestList
        self.userid = id
    }
    func getPost(forPage: Int,handler: @escaping (([CompletePost]?,Int)->()) ) {
        var queryparams = "?"
        for value in self.interestList{
            queryparams = queryparams+"interest=\(value)&"
        }
        PostsRestManager.shared.getPostOnUserInterest(userId: /self.userid, interestString: queryparams, pageNumber: forPage) { (postList, statusCode) -> (Void) in
            var responseList = [CompletePost]()
            for post in postList?.posts ?? []{
                let completepost = CompletePost(post: post)
                responseList.append(completepost)
            }
            handler(responseList,statusCode)
        }
    }
}

class SinglePostDataSource:RestDataSource{
    private var postid:String
    init(postId:String){
        self.postid = postId
    }
    func getPost(forPage: Int, handler: @escaping (([CompletePost]?, Int) -> ())) {
        PostsRestManager.shared.getPostByPostId(userId: /MentorzPostViewer.shared.dataSource?.getUserId(), postId: self.postid) { (postReceived, statusCode) in
            if let post = postReceived{
            handler([CompletePost(post: post)],statusCode)
            }else{
                handler(nil,statusCode)
            }
        }
    }
}
