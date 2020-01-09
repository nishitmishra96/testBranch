//
//  PostsRestManager.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 26/11/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.
//

import Foundation
import Moya
import ObjectMapper

class PostsRestManager:NSObject{
    static var shared = PostsRestManager()
    private var postProvider = MoyaProvider<ApiCollection>()
    func getPosts(userId:String,pageNumber:Int,handler: @escaping ((PostList?,Int)->(Void))){
        postProvider.request(.getMyBoardPost(userId: userId, pageNumber: pageNumber)) { (response) in
            print(response)
            switch response{
            case .success( let result):
                do{
                    let responseString = try result.mapString()
                    print("Done")
                    let postlist = PostList(JSONString: responseString)
                    handler(postlist,result.statusCode)
                }
                catch{
                    print("Not Done")
                    handler(nil,result.statusCode)
                }

            case .failure( _):
                handler(nil,response.error?.response?.statusCode ?? 0)
            }
        }
    }
    
    func getMyPost(userId:String,pageNumber:Int,handler:@escaping ((PostList?,Int)->(Void))){
        postProvider.request(.getMyPosts(userId: userId, pageNumber: pageNumber)) { (response) in
            print(response)
            switch response{
            case .success( let result):
                do{
                    let responseDic = try JSONSerialization.jsonObject(with: result.data, options: []) as? [String:Any]
                    print("Done")
                    handler(PostList(JSON: responseDic ?? [:]),result.statusCode)
                }
                catch{
                    print("Not Done")
                    handler(nil,result.statusCode)
                }

            case .failure(let error):
                handler(nil,error.response?.statusCode ?? 0)
            }
        }
        
    }
    
    func userLikedThePost(postId:String,userId:String,handler:@escaping ((Int)->())){
        
        postProvider.request(.likeAPost(postId: postId, userId: userId)) { (response) in
            switch response{
            case .success(let result):
                print("LIKED ",result.statusCode)
                handler(result.statusCode)
            case .failure(let error):
                print("LIKE failed 309")
                handler((response.error?.errorCode) ?? 309)
            }
        }
    }
    
    func userUnlikedThePost(postId:String,userId:String,handler:@escaping ((Int)->())){
        postProvider.request(.unlikeAPost(postId: postId, userId: userId)) { (response) in
            switch response{
            case .success(let result):
                print("Unliked ",result.statusCode)
                handler(result.statusCode)
            case .failure(let error):
                print("UNLIKE failed 309")
                handler((response.error?.errorCode) ?? 309)
            }
        }
    }
    
    func userCommentedOnAPost(userId:String,postId:String,comment:String,handler:@escaping ((Int)->())){
        postProvider.request(.commentOnAPost(postId: postId, userId: userId, comment: comment)) { (response) in
            switch response{
            case .success(let result):
                print("comment status ",result.statusCode)
                handler(result.statusCode)
            case .failure(let error):
                print("comment failed 309")
                handler(309)
            }
        }
    }
    
    func getPostOnUserInterest(userId:String,interestString:String,pageNumber:Int,handler:@escaping (PostList?,Int)->(Void)){
            
        postProvider.request(.getPostByInterest(userId: userId, interestString: interestString, pageNumber: pageNumber)) { (response) in
            switch response{
            case .success( let result):
                do{
                    let responseDic = try JSONSerialization.jsonObject(with: result.data, options: []) as? [String:Any]
                    print("Done")
                    handler(PostList(JSON: responseDic ?? [:]),result.statusCode)
                }
                catch{
                    print("Not Done")
                    handler(nil,result.statusCode)
                }

            case .failure(let error):
                handler(nil,/error.response?.statusCode)
            }
        }
    }
    
    func reportPost(userId: String, postId: String, type: String,handler:@escaping ((Int?)->())){
        postProvider.request(.reportAbuse(userId: userId, postId: postId, type: type)) { (response) in
            print(response)
            switch response{
            case .success( let result):
                    handler(/result.statusCode)
            case .failure(let error):
                handler(/error.response?.statusCode)
            }
        }
    }
    
    func updatePostViewCount(userId: String?, postId: String?,handler:@escaping ((Int?)->())){
        postProvider.request(.viewPost(userId: /userId, postId: /postId)) { (response) in
            switch response{
            case .success( let result):
                    handler(/result.statusCode)
            case .failure(let error):
                handler(/error.response?.statusCode)
            }
        }
    }
    
    func getUserRating(userId:String?,handler:@escaping ((Rating?,Int?)->())){
        postProvider.request(.getUserRating(userId: /userId)) { (response) in
            switch response{
            case .success(let result):
                do{
                    let responseString = try result.mapString()
                    let rating = Rating(JSONString: responseString)
                    handler(rating ?? Rating(),result.statusCode)
                }catch{
                    handler(nil,result.statusCode)
                }
            case .failure(let error):
                handler(nil,/error.response?.statusCode)
            }
        }
    }
    
    func getProfileImageWith(userId:String,handler:@escaping ((ProfileImage?,Int?)->())){
        postProvider.request(.getProfileImage(userId: userId)) { (response) in
        switch response{
            case .success(let result):
                do{
                    let responseString = try result.mapString()
                    let rating = ProfileImage(JSONString: responseString)
                    handler(rating,result.statusCode)
                }catch{
                    handler(nil,HttpResponseCodes.SomethingWentWrong.rawValue)
                }
            case .failure(let error):
                handler(nil,error.response?.statusCode)
            }
        }
    }
    func getCommentsforPostId(userId: String?, postId: String?, pageNumber: Int,handler:@escaping ((CommentList?,Int?)->())){
        postProvider.request(.getCommentList(userId: /userId, postId: /postId, pageNumber: pageNumber)) { (response) in
            switch response{
            case .success(let result):
                do{
                    let responseString = try result.mapString()
                    let commentList = CommentList(JSONString: responseString)
                    handler(commentList,result.statusCode)
                }catch{
                    handler(nil,HttpResponseCodes.SomethingWentWrong.rawValue)
                }
                case .failure(let error):
                    handler(nil,error.response?.statusCode)
            }
        }
    }
    
    func deleteCommentWith(userId:String,postId:String,commentId:String,handler:@escaping ((Int?)->())){
        postProvider.request(.userDeletedComment(userId: userId, postId: postId, commentId: commentId)) { (response) in
            switch response{
            case .success(let result):
                handler(result.statusCode)
            case .failure(let error):
                handler(error.response?.statusCode)
            }
        }
    }
    
    func uploadSessionURI(name:String,mime:String,handler:@escaping ((String?,Int?)->())){
        postProvider.request(.getUploadSessionURI(name: name, mime: mime)) { (response) in
            switch response{
            case .success(let result) :
                do{
                    let responseString = try result.mapString()
                    let googleUrl = GoogleURL(JSONString: responseString)
                    handler(/googleUrl?.value,result.statusCode)
                }catch{
                    handler("",HttpResponseCodes.SomethingWentWrong.rawValue)
                }
            case .failure(let error) :
                handler("",error.response?.statusCode)
            }
        }
    }
    func getSignedURL(name:String,handler:@escaping ((String?,Int?)->())){
        postProvider.request(.getSignedURL(contentName: name)) { (response) in
            switch response{
            case .success(let result) :
                do{
                    let responseString = try result.mapString()
                    let googleUrl = GoogleURL(JSONString: responseString)
                    handler(/googleUrl?.value,result.statusCode)
                }catch{
                    handler("",HttpResponseCodes.SomethingWentWrong.rawValue)
                }
            case .failure(let error) :
                handler("",error.response?.statusCode)
            }
        }
    }
    func uploadPostToMentorzServer(userId:String,newPost:NewPost,handler:@escaping ((Post?,Int)->())){
        postProvider.request(.uploadPost(userId: userId, newPost: newPost)) { (response) in
            switch response{
            case .success(let result) :
                do{
                    let responseString = try result.mapString()
                    let post = Post(JSONString: responseString)
                    handler(post!,result.statusCode)
                }catch{
                    handler(Post(),HttpResponseCodes.SomethingWentWrong.rawValue)
                }
            case .failure(let error) :
                handler(Post(),/error.response?.statusCode)
            }
        }
    }
}
