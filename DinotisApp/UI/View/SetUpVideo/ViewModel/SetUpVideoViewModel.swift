//
//  SetUpVideoViewModel.swift
//  DinotisApp
//
//  Created by Irham Naufal on 27/10/23.
//

import DinotisData
import SwiftUI
import AVKit

struct DummyVideoData: Identifiable {
    var id: UUID = .init()
    var url: String
    var thumbnail: String
    var isSelected: Bool = false
    var duration: String = "1:01:45"
}

enum ViewerType {
    case publicly
    case subscriber
}

final class SetUpVideoViewModel: ObservableObject {
    
    @Published var data: UserMeetingData
    @Published var videos: [DummyVideoData] = [
        .init(url: "https://storage.googleapis.com/dinotis-recording-1/recordings/bbb789d0-f056-4c89-b936-7bd5051c72b4_1697192142005.mp4", thumbnail: "https://static.wikia.nocookie.net/kpop/images/3/33/NewJeans_Get_Up_group_concept_photo_13.png/revision/latest?cb=20230722054537"),
        .init(url: "https://storage.googleapis.com/dinotis-recording-1/recordings/bbb789d0-f056-4c89-b936-7bd5051c72b4_1697192142005.mp4", thumbnail: "https://static.wikia.nocookie.net/kpop/images/3/33/NewJeans_Get_Up_group_concept_photo_13.png/revision/latest?cb=20230722054537"),
        .init(url: "https://storage.googleapis.com/dinotis-recording-1/recordings/bbb789d0-f056-4c89-b936-7bd5051c72b4_1697192142005.mp4", thumbnail: "https://static.wikia.nocookie.net/kpop/images/3/33/NewJeans_Get_Up_group_concept_photo_13.png/revision/latest?cb=20230722054537"),
    ]
    
    @Published var isShowArchiveSheet = false
    @Published var isShowUploadeSheet = false
    @Published var isShowHoverVideo = false
    
    @Published var thumbnails: [UIImage] = []
    @Published var isShowImagePicker: [Bool] = []
    
    @Published var currentVideo = ""
    
    @Published var viewerType: ViewerType? = .publicly
    
    var backToHome: () -> Void
    
    init(data: UserMeetingData, backToHome: @escaping () -> Void) {
        self.data = data
        self.backToHome = backToHome
    }
    
    func getData() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if self.isShowImagePicker.isEmpty {
                self.isShowImagePicker = self.videos.compactMap({ _ in
                    false
                })
            }
            
            if self.thumbnails.isEmpty {
                self.thumbnails = self.videos.compactMap({ _ in
                    UIImage()
                })
            }
        }
    }
    
    func showHoverVideo(_ urlString: String) {
        DispatchQueue.main.async { [weak self] in
            self?.currentVideo = urlString
            
            withAnimation {
                self?.isShowHoverVideo = true
            }
        }
    }
}
