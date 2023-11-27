//
//  GetVideoListUseCase.swift
//
//
//  Created by Irham Naufal on 25/11/23.
//

import Foundation

public protocol GetVideoListUseCase {
    func execute(with param: VideoListRequest) async -> Result<MineVideoResponse, Error>
}
