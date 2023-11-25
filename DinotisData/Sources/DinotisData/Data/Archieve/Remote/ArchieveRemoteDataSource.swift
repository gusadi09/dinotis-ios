//
//  File.swift
//  
//
//  Created by Gus Adi on 14/11/23.
//

import Foundation

public protocol ArchieveRemoteDataSource {
    func postVideo(_ body: VideosRequest) async throws -> VideosResponse
    func getMineVideo(with query: MineVideoRequest) async throws -> MineVideoResponse
    func deleteVideo(on id: String) async throws -> SuccessResponse
    func editVideo(on id: String, with body: VideosRequest) async throws -> SuccessResponse
    func getDetailVideo(on id: String) async throws -> DetailVideosResponse
    func getComments(videoId: String, skip: Int, take: Int) async throws -> CommentsResponse
    func postComment(videoId: String, comment: String) async throws -> SuccessResponse
    func getArchived(skip: Int, take: Int) async throws -> ArchivedResponse
    func getVideoList(with param: VideoListRequest) async throws -> MineVideoResponse
}
