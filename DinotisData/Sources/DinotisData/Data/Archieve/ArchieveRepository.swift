//
//  File.swift
//  
//
//  Created by Gus Adi on 14/11/23.
//

import Foundation

public protocol ArchieveRepository {
    func providePostVideo(_ body: VideosRequest) async throws -> VideosResponse
    func provideGetMineVideo(with query: MineVideoRequest) async throws -> MineVideoResponse
    func provideDeleteVideo(on id: String) async throws -> SuccessResponse
    func provideEditVideo(on id: String, with body: VideosRequest) async throws -> SuccessResponse
    func provideGetDetailVideo(on id: String) async throws -> DetailVideosResponse
    func provideGetComments(videoId: String, skip: Int, take: Int) async throws -> CommentsResponse
    func providePostComment(videoId: String, comment: String) async throws -> SuccessResponse
    func provideGetArchived(skip: Int, take: Int) async throws -> ArchivedResponse
    func providePostArchive(meetingId: String) async throws -> SuccessResponse
    func provideGetVideoList(with param: VideoListRequest) async throws -> MineVideoResponse
}
