//
//  File.swift
//  
//
//  Created by Gus Adi on 02/11/23.
//

import Foundation
import Moya
import Photos

public enum SignedURLTargertType {
    case uploadSigned(String, String, QueryParamsData, HeaderData, Data, String)
    case downloadVideo(String, String)
}

extension SignedURLTargertType: TargetType {
    public var parameters: [String: Any] {
        switch self {
        case .uploadSigned(_, _, let param, _, _, _):
            var processed = QueryParamsData()
            if let XGoogAlgorithm = param.XGoogAlgorithm?.removingPercentEncoding, 
                let XGoogCredential = param.XGoogCredential?.removingPercentEncoding,
                let XGoogDate = param.XGoogDate?.removingPercentEncoding,
                let XGoogExpires = param.XGoogExpires?.removingPercentEncoding,
                let XGoogSignedHeaders = param.XGoogSignedHeaders?.removingPercentEncoding,
                let XGoogSignature = param.XGoogSignature?.removingPercentEncoding
            {
                processed = QueryParamsData(XGoogAlgorithm: XGoogAlgorithm, XGoogCredential: XGoogCredential, XGoogDate: XGoogDate, XGoogExpires: XGoogExpires, XGoogSignedHeaders: XGoogSignedHeaders, XGoogSignature: XGoogSignature)
                
                return processed.toJSON()
            } else {
                return param.toJSON()
            }
            
        case .downloadVideo(_, _):
            return [:]
        }
        
    }
    
    public var baseURL: URL {
        switch self {
        case .uploadSigned(let base, _, _, _, _, _):
            return URL(string: base) ?? (NSURL() as URL)
        case .downloadVideo(let url, _):
            return URL(string: url) ?? (NSURL() as URL)
        }
        
    }
    
    public var path: String {
        switch self {
        case .uploadSigned(_, let path, _, _, _, _):
            return path
        case .downloadVideo(_, _):
            return ""
        }
    }
    
    var parameterEncoding: Moya.ParameterEncoding {
        switch self {
        case .uploadSigned:
            return URLEncoding.default
        case .downloadVideo(_, _):
            return URLEncoding.default
        }
        
    }
    
    public var method: Moya.Method {
        switch self {
        case .uploadSigned:
            return .put
        case .downloadVideo(_, _):
            return .get
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .uploadSigned(_, _, _, _, let video, _):
            return .requestCompositeData(bodyData: video, urlParameters: parameters)
        case .downloadVideo(let url, _):
            return .downloadParameters(parameters: parameters, encoding: URLEncoding.default) { temporaryURL, response in
                let documentsURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let fileURL = documentsURL?.appendingPathComponent("\(url.split(separator: "/").last ?? "")")
                
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL ?? (NSURL() as URL))
                }) { completed, error in
                    if completed {
                        print("Video is saved!")
                    }
                }
                
                return (fileURL ?? (NSURL() as URL), [.removePreviousFile, .createIntermediateDirectories])
            }
        }
    }
    
    public var headers: [String : String]? {
        switch self {
        case .uploadSigned(_, _, _, let header, _, _):
            return [
                "Content-Type": header.ContentType.orEmpty()
            ]
        case .downloadVideo(_, let filename):
            return [
                "Content-Disposition": "attachment; filename=\"\(filename)\""
            ]
        }
        
    }
}
