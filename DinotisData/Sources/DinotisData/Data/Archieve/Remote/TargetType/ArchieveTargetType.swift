//
//  File.swift
//  
//
//  Created by Gus Adi on 14/11/23.
//

import Foundation
import Moya

public enum ArchieveTargetType {
    case postVideos(VideosRequest)
    case getMineVideo(MineVideoRequest)
    case deleteVideo(String)
    case getDetailVideo(String)
    case editVideo(String, VideosRequest)
    case postComment(String, String)
    case getComments(String, Int, Int)
    case getArchieved(Int, Int)
    case getVideoList(VideoListRequest)
}

extension ArchieveTargetType: DinotisTargetType, AccessTokenAuthorizable {
    var parameters: [String : Any] {
        switch self {
        case .postVideos(let req):
            return req.toJSON()
        case .getMineVideo(let req):
            return req.toJSON()
        case .deleteVideo(_):
            return [:]
        case .getDetailVideo(_):
            return [:]
        case .editVideo(_, let body):
            return body.toJSON()
        case .postComment(let id, let comment):
            return [
                "videoId": id,
                "comment": comment
            ]
        case .getComments(_, let skip, let take):
            return [
                "skip": skip,
                "take": take
            ]
        case .getArchieved(let skip, let take):
            return [
                "skip": skip,
                "take": take
            ]
        case .getVideoList(let param):
            return param.toJSON()
        }
    }
    
    public var headers: [String : String]? {
        switch self {
        case .postVideos(_):
            return [:]
        case .getMineVideo(_):
            return [:]
        case .deleteVideo(_):
            return [:]
        case .getDetailVideo(_):
            return [:]
        case .editVideo(_, _):
            return [:]
        case .postComment(_, _):
            return [:]
        case .getComments(_, _, _):
            return [:]
        case .getArchieved(_, _):
            return [:]
        case .getVideoList:
            return [:]
        }
        
    }
    
    public var authorizationType: AuthorizationType? {
        return .bearer
    }
    
    var parameterEncoding: Moya.ParameterEncoding {
        switch self {
        case .postVideos(_):
            return JSONEncoding.default
        case .getMineVideo(_):
            return URLEncoding.default
        case .deleteVideo(_):
            return URLEncoding.default
        case .getDetailVideo(_):
            return URLEncoding.default
        case .editVideo(_, _):
            return JSONEncoding.default
        case .postComment(_, _):
            return JSONEncoding.default
        case .getComments(_, _, _):
            return URLEncoding.default
        case .getArchieved(_, _):
            return URLEncoding.default
        case .getVideoList:
            return URLEncoding.default
        }
    }
    
    public var task: Task {
        switch self {
        default:
            return .requestParameters(parameters: parameters, encoding: parameterEncoding)
        }
    }
    
    public var path: String {
        switch self {
        case .postVideos(_):
            return "/videos"
        case .getMineVideo(_):
            return "/videos/mine"
        case .deleteVideo(let id):
            return "/videos/\(id)"
        case .getDetailVideo(let id):
            return "/videos/\(id)"
        case .editVideo(let id, _):
            return "/videos/\(id)"
        case .postComment(_, _):
            return "/comments"
        case .getComments(let id, _, _):
            return "/comments/video/\(id)"
        case .getArchieved(_, _):
            return "/videos/archived"
        case .getVideoList(let param):
            return "/videos/\(param.username)/user"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .postVideos(_):
            return .post
        case .getMineVideo(_):
            return .get
        case .deleteVideo(_):
            return .delete
        case .getDetailVideo(_):
            return .get
        case .editVideo(_, _):
            return .put
        case .postComment(_, _):
            return .post
        case .getComments(_, _, _):
            return .get
        case .getArchieved(_, _):
            return .get
        case .getVideoList:
            return .get
        }
    }
}
