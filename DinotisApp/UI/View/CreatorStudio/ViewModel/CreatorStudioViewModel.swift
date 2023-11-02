//
//  CreatorStudioViewModel.swift
//  DinotisApp
//
//  Created by Irham Naufal on 30/10/23.
//

import SwiftUI
import DinotisDesignSystem
import AVFoundation

struct DummyArchiveModel: Identifiable {
    var id: UUID = .init()
    var title: String = "Serba serbi Program Hamil Alami dan Mandiri bebas bebas dalam hidup"
    var videoCount: Int = 5
    var date: Date = .now
}

enum StudioVideoFilter {
    case earliest, latest, recorded, popular, archive
}

enum UploadState {
    case initial, select, uploading, success, failed
}

final class CreatorStudioViewModel: ObservableObject {
    
    @Published var route: HomeRouting?
    
    @Published var profileImage = "https://dinotis-public.s3.ap-southeast-1.amazonaws.com/3001accb766dd9c2d47358fbf35101e6e.jpeg"
    
    @Published var uploadProgress: Float = 0.0
    
    @Published var isShowPicker = false
    @Published var isShowImagePicker = false
    @Published var isShowPostEditor = false
    @Published var isShowHoverVideo = false
    @Published var isShowUploadSheet = false
    @Published var isShowCancelUploadSheet = false
    
    @Published var uploadState: UploadState = .initial
    
    @Published var currentVideo: DummyVideoModel = .init(title: "", url: nil, thumbnail: "")
    @Published var thumbnail = UIImage()
    
    @Published var videos: [DummyVideoModel] = [
        .init(title: "Lorem ipsum dolor sit amet consectetur. Aliquet vitae id pellentesque est ",
              description: "Lorem ipsum dolor sit amet consectetur. Mattis et ut fusce eget turpis in tellus sit. Ultrices est rhoncus vestibulum lectus non. Dui duis etiam dictum quam ut condimentum lacinia. Lorem egestas duis in sollicitudin diam in nec. Eu tincidunt ultricies et id semper erat morbi sed urna. Viverra pulvinar ultrices viverra nisi ac et viverra. Habitasse quis et volutpat dolor lectus aliquet.",
              thumbnail: "https://esports.id/img/article/854920211125095801.jpg"),
        .init(title: "Lorem ipsum dolor sit amet consectetur. Aliquet vitae id pellentesque est ",
              description: "Lorem ipsum dolor sit amet consectetur. Mattis et ut fusce eget turpis in tellus sit. Ultrices est rhoncus vestibulum lectus non. Dui duis etiam dictum quam ut condimentum lacinia. Lorem egestas duis in sollicitudin diam in nec. Eu tincidunt ultricies et id semper erat morbi sed urna. Viverra pulvinar ultrices viverra nisi ac et viverra. Habitasse quis et volutpat dolor lectus aliquet.",
              thumbnail: "https://esports.id/img/article/854920211125095801.jpg"),
        .init(title: "Lorem ipsum dolor sit amet consectetur. Aliquet vitae id pellentesque est ",
              description: "Lorem ipsum dolor sit amet consectetur. Mattis et ut fusce eget turpis in tellus sit. Ultrices est rhoncus vestibulum lectus non. Dui duis etiam dictum quam ut condimentum lacinia. Lorem egestas duis in sollicitudin diam in nec. Eu tincidunt ultricies et id semper erat morbi sed urna. Viverra pulvinar ultrices viverra nisi ac et viverra. Habitasse quis et volutpat dolor lectus aliquet.",
              thumbnail: "https://esports.id/img/article/854920211125095801.jpg"),
    ]
    
    @Published var archivedVideo: [DummyArchiveModel] = [.init(), .init(), .init(), .init()]
    
    @Published var currentSection: StudioVideoFilter = .latest
    @Published var sections: [StudioVideoFilter] = [.latest, .recorded, .popular, .earliest, .archive]
    
    var backToHome: () -> Void
    
    var uploadStatusText: String {
        switch uploadState {
        case .success:
            LocalizableText.generalSuccess
        case .failed:
            LocalizableText.uploadFailedTitle
        default:
            LocalizableText.uploadingLabel
        }
    }
    
    init(backToHome: @escaping () -> Void) {
        self.backToHome = backToHome
    }
    
    func chipText(_ section: StudioVideoFilter) -> String {
        switch section {
        case .earliest:
            LocalizableText.sortEarliest
        case .latest:
            LocalizableText.sortLatest
        case .recorded:
            LocalizableText.recordedLabel
        case .popular:
            LocalizableText.popularLabel
        case .archive:
            LocalizableText.archiveLabel
        }
    }
    
    func viewerTypeText(_ type: ViewerType) -> String {
        switch type {
        case .publicly:
            LocalizableText.publicLabel
        case .subscriber:
            LocalizableText.subscriberLabel
        }
    }
    
    func dateFormatter(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, yyyy"
        return formatter.string(from: date)
    }
    
    func editVideo(_ video: DummyVideoModel) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.currentVideo = video
            self.isShowPostEditor = true
        }
    }
    
    func showHoverVideo() {
        DispatchQueue.main.async { [weak self] in
            withAnimation {
                self?.isShowHoverVideo = true
            }
        }
    }
    
    func showVideoPicker() {
        DispatchQueue.main.async { [weak self] in
            self?.isShowPicker = true
            self?.uploadState = .select
        }
    }
    
    func showEditorWhenPosting() {
        if let url = currentVideo.url, uploadState == .select {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.thumbnail = self.createThumbnail(url: url)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) { [weak self] in
                self?.isShowPostEditor = true
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.uploadState = .initial
            }
        }
    }
    
    func dismissEditor() {
        DispatchQueue.main.async { [weak self] in
            self?.isShowPostEditor = false
            self?.uploadState = .initial
            self?.currentVideo = .init(title: "", url: nil, thumbnail: "")
            self?.thumbnail = UIImage()
        }
    }
    
    func createThumbnail(url: URL) -> UIImage {
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
          print(error.localizedDescription)
            return UIImage()
        }
    }
    
    func startUpload() {
        DispatchQueue.main.async { [weak self] in
            self?.isShowPostEditor = false
            self?.uploadState = .uploading
            self?.currentVideo = .init(title: "", url: nil, thumbnail: "")
            self?.thumbnail = UIImage()
        }
        
        _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.uploadProgress < 1.0 {
                DispatchQueue.main.async { [weak self] in
                    self?.uploadProgress += 0.2
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.uploadState = .success
                    timer.invalidate()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                    withAnimation {
                        self?.uploadState = .initial
                        self?.uploadProgress = 0.0
                    }
                }
            }
        }
    }
    
    func disablePostButton() -> Bool {
        currentVideo.title.count < 5 || currentVideo.description.count < 5
    }
    
    func routeToSessionRecordingList() {
        let viewModel = SessionRecordingListViewModel(backToHome: { self.backToHome() })
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .sessionRecordingList(viewModel: viewModel)
        }
    }
    
    func routeToDetailVideo() {
        let viewModel = DetailVideoViewModel(backToHome: { self.backToHome() })
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .detailVideo(viewModel: viewModel)
        }
    }
}
