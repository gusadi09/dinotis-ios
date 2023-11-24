//
//  File.swift
//  
//
//  Created by Gus Adi on 14/11/23.
//

import Foundation

public final class ArchieveDefaultRepository: ArchieveRepository {
    
    private let remote: ArchieveRemoteDataSource
    
    public init(remote: ArchieveRemoteDataSource = ArchieveDefaultRemoteDataSource()) {
        self.remote = remote
    }
    
    public func providePostVideo(_ body: VideosRequest) async throws -> VideosResponse {
        try await self.remote.postVideo(body)
    }
    
    public func provideGetMineVideo(with query: MineVideoRequest) async throws -> MineVideoResponse {
        try await self.remote.getMineVideo(with: query)
    }
    
    public func provideDeleteVideo(on id: String) async throws -> SuccessResponse {
        try await self.remote.deleteVideo(on: id)
    }
    
    public func provideEditVideo(on id: String, with body: VideosRequest) async throws -> SuccessResponse {
        try await self.remote.editVideo(on: id, with: body)
    }
    
    public func provideGetDetailVideo(on id: String) async throws -> DetailVideosResponse {
        try await self.remote.getDetailVideo(on: id)
    }
    
    public func providePostComment(videoId: String, comment: String) async throws -> SuccessResponse {
        try await self.remote.postComment(videoId: videoId, comment: comment)
    }
    
    public func provideGetComments(videoId: String, skip: Int, take: Int) async throws -> CommentsResponse {
        try await self.remote.getComments(videoId: videoId, skip: skip, take: take)
    }
    
    public func provideGetArchived(skip: Int, take: Int) async throws -> ArchivedResponse {
        try await self.remote.getArchived(skip: skip, take: take)
    }
}
