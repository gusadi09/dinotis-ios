//
//  File.swift
//  
//
//  Created by Gus Adi on 14/11/23.
//

import Foundation
import Moya

public final class ArchieveDefaultRemoteDataSource: ArchieveRemoteDataSource {
    
    private let provider: MoyaProvider<ArchieveTargetType>
    
    public init(provider: MoyaProvider<ArchieveTargetType> = .defaultProvider()) {
        self.provider = provider
    }
    
    public func postVideo(_ body: VideosRequest) async throws -> VideosResponse {
        try await self.provider.request(.postVideos(body), model: VideosResponse.self)
    }
    
    public func getMineVideo(with query: MineVideoRequest) async throws -> MineVideoResponse {
        try await self.provider.request(.getMineVideo(query), model: MineVideoResponse.self)
    }
    
    public func deleteVideo(on id: String) async throws -> SuccessResponse {
        try await self.provider.request(.deleteVideo(id), model: SuccessResponse.self)
    }
    
    public func editVideo(on id: String, with body: VideosRequest) async throws -> SuccessResponse {
        try await self.provider.request(.editVideo(id, body), model: SuccessResponse.self)
    }
    
    public func getDetailVideo(on id: String) async throws -> DetailVideosResponse {
        try await self.provider.request(.getDetailVideo(id), model: DetailVideosResponse.self)
    }
    
    public func getComments(videoId: String, skip: Int, take: Int) async throws -> CommentsResponse {
        try await self.provider.request(.getComments(videoId, skip, take), model: CommentsResponse.self)
    }
    
    public func postComment(videoId: String, comment: String) async throws -> SuccessResponse {
        try await self.provider.request(.postComment(videoId, comment), model: SuccessResponse.self)
    }
    
    public func getArchived(skip: Int, take: Int) async throws -> ArchivedResponse {
        try await self.provider.request(.getArchieved(skip, take), model: ArchivedResponse.self)
    }
}
