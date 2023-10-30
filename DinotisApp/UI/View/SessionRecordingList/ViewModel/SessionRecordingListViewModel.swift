//
//  SessionRecordingListViewModel.swift
//  DinotisApp
//
//  Created by Irham Naufal on 30/10/23.
//

import Foundation

struct DummyDownloadVideo: Identifiable {
    var id: UUID = .init()
    var title: String
    var thumbnail: String = "https://static.wikia.nocookie.net/kpop/images/3/33/NewJeans_Get_Up_group_concept_photo_13.png/revision/latest?cb=20230722054537"
    var size: String = "1.1 MB"
    var isDownloading: Bool = false
}

final class SessionRecordingListViewModel: ObservableObject {
    
    @Published var videos: [DummyDownloadVideo] = [
//        .init(title: "Recording 1"),
//        .init(title: "Recording 2"),
//        .init(title: "Recording 3"),
//        .init(title: "Recording 4"),
    ]
    
    var backToHome: () -> Void
    
    init(backToHome: @escaping () -> Void) {
        self.backToHome = backToHome
    }
}
