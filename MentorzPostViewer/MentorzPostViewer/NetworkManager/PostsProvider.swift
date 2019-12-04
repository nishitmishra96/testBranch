//
//  PostsProvider.swift
//  MentorzPostViewer
//
//  Created by Nishit Mishra on 26/11/19.
//  Copyright © 2019 Nishit Mishra. All rights reserved.
//

import Foundation
import Moya

enum ApiCollection{
    case getMyBoardPost(userId:String,pageNumber:Int)
    case getPostByID(userId:String,pageNumber:Int)
    case likeAPost(postId:String,userId:String)
    case unlikeAPost(postId:String,userId:String)
    case commentOnAPost(postId:String,userId:String,comment:String)
    case getMyPosts(userId:String,pageNumber:Int)
    case getPostByInterest(userId:String,interestString:String,pageNumber:Int)
    case reportAbuse(userId:String,postId:String,type:String)
    case viewPost(userId:String,postId:String)
    case getUserRating(userId:String)
    case getProfileImage(userId:String)
}
extension ApiCollection:TargetType{
    var headers: [String : String]? {
        return ["Accept":"application/json","Content-Type":"application/json","user-agent":"hhhhh","oauth-token":"1575465070881:rOmUFUoCYYBpFWKP/DZAjH63QFisKnHrHB0zNvBGcBs=_611"]
    }
    
    var baseURL: URL {
        switch self {
        case .getPostByInterest(userId: let userid, interestString: let interestString, pageNumber: let pagenumber):
            return URL(string: URLGenerator().baseUrl + "/mentorz/api/v3/\(userid)/post/search\(interestString)pageNo=\(pagenumber)" )!

        default:
            return URL(string: URLGenerator().baseUrl )!
        }
    }
    
    var path: String {
        switch self {
        case .getMyBoardPost(let userID,_):
            return "/mentorz/api/v3/user/\(userID)/board"
        case .getPostByID(let userID,let page):
            return "/mentorz/api/v3/0/post/friend/\(userID)?pageNo=\(page)"
        case .likeAPost(let postId,let userId):
            return "/mentorz/api/v3/\(userId)/post/\(postId)/like"
        case .commentOnAPost(let postId,let userId,_):
            return "/mentorz/api/v3/\(userId)/post/\(postId)/comment"
        case .getMyPosts(let userId,_):
            return "/mentorz/api/v3/\(userId)/post/friend/\(userId)"
        case .getPostByInterest(_, _, _):
            return ""
        case .unlikeAPost(let postId, let userId):
            return "/mentorz/api/v3/\(userId)/post/\(postId)/unlike"
        case .reportAbuse(let userId, let postId, _):
            return "/mentorz/api/v3/\(userId)/post/\(postId)/abuse"
        case .viewPost(let userId, let postId):
            return "/mentorz/api/v3/\(userId)/post/\(postId)/view"
        case .getUserRating(let userId):
            return "/mentorz/api/v3/user/\(userId)/rating"
        case .getProfileImage(let userId):
            return "/mentorz/api/v3/user/\(userId)/profile/image"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getPostByID,.getMyBoardPost,.getMyPosts,.getUserRating,.getPostByInterest,.getProfileImage:
            return .get
        case .likeAPost,.unlikeAPost,.reportAbuse,.viewPost:
            return .post
        case .commentOnAPost:
            return .put
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .getMyBoardPost(_,let page):
            return .requestCompositeData(bodyData: Data(), urlParameters: ["pageNo":page])
        case .getPostByID:
            return .requestPlain
        case .likeAPost(_,_):
            return .requestPlain
        case .commentOnAPost(_,_, let comment):
            return .requestCompositeParameters(bodyParameters: ["comment":comment], bodyEncoding: JSONEncoding.default, urlParameters: [:])
        case .getMyPosts(_, let pageNumber):
            return .requestCompositeData(bodyData: Data(), urlParameters: ["pageNo":pageNumber])
        case .getPostByInterest( _, _, _):
            return .requestPlain
        case .unlikeAPost( _, _):
            return .requestPlain
        case .reportAbuse(_, _,let type):
            return .requestParameters(parameters: ["abuse_type":type], encoding: JSONEncoding.default)
        case .viewPost(_,_):
            return .requestPlain
        case .getUserRating(_):
            return .requestPlain
        case .getProfileImage(_):
            return .requestPlain
        }
    }
    var validationType: ValidationType {
        return .successCodes
    }
    
}
