//
//  File.swift
//  
//
//  Created by Gus Adi on 13/11/23.
//

import Foundation
import Moya

public protocol DownloadVideoUseCase {
    func execute(url: String, filename: String, isCancel: Bool, progress: ProgressBlock?) async -> Result<String, Error>
}

