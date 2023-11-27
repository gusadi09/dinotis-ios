//
//  SetUpVideoViewModel.swift
//  DinotisApp
//
//  Created by Irham Naufal on 27/10/23.
//

import DinotisData
import SwiftUI
import AVKit
import OneSignal

enum ViewerType {
    case publicly
    case subscriber
}

extension ViewerType {
    var type: String {
        switch self {
        case .publicly:
            return "PUBLIC"
        case .subscriber:
            return "SUBSCRIBER"
        }
    }
}

final class SetUpVideoViewModel: ObservableObject {
    
    private let uploadImageUseCase: SinglePhotoUseCase
    private let postVideoUseCase: PostVideoUseCase
    private let getRecordingsUseCase: GetRecordingsUseCase
    private let archiveRecordUseCase: ArchiveRecordUseCase
    private var stateObservable = StateObservable.shared
    
    @Published var currentVideo: VideosRequest = .init(cover: "", title: "", description: "", videoUrl: "", meetingId: nil, audienceType: ViewerType.publicly.type)
    @Published var data: MeetingDetailResponse?
    @Published var videos = [RecordingData]()
    @Published var selectedIdx: Int? = nil
    
    @Published var isLoadingUpload = false
    @Published var isLoadingArchieve = false
    @Published var isLoading = false
    @Published var isError = false
    @Published var isRefreshFailed = false
    @Published var error = ""
    
    @Published var isShowArchiveSheet = false
    @Published var isShowUploadeSheet = false
    @Published var isShowHoverVideo = false
    
    @Published var thumbnails: [UIImage] = []
    @Published var isShowImagePicker = [Bool]()
    
    @Published var viewerType: ViewerType = .publicly
    @Published var route: HomeRouting?
    
    var backToHome: () -> Void
    var backToScheduleDetail: () -> Void
    
    init(
        data: MeetingDetailResponse?,
        backToHome: @escaping () -> Void,
        backToScheduleDetail: @escaping () -> Void,
        uploadImageUseCase: SinglePhotoUseCase = SinglePhotoDefaultUseCase(),
        postVideoUseCase: PostVideoUseCase = PostVideoDefaultUseCase(),
        getRecordingsUseCase: GetRecordingsUseCase = GetRecordingsDefaultUseCase(),
        archiveRecordUseCase: ArchiveRecordUseCase = ArchiveRecordDefaultUseCase()
    ) {
        self.data = data
        self.backToHome = backToHome
        self.backToScheduleDetail = backToScheduleDetail
        self.uploadImageUseCase = uploadImageUseCase
        self.postVideoUseCase = postVideoUseCase
        self.getRecordingsUseCase = getRecordingsUseCase
        self.archiveRecordUseCase = archiveRecordUseCase
    }
    
    func fetchStarted() {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = true
            
            self?.isError = false
            self?.isRefreshFailed = false
            self?.error = ""
        }
    }
    
    func onGetRecordings() {
        self.isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: .init(block: {
            Task {
                await self.getRecordings()
            }
        }))
        
    }
    
    func formatSecondsToTimestamp(seconds: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad

        guard let formattedString = formatter.string(from: TimeInterval(seconds)) else {
            return "00:00:00"
        }

        return formattedString
    }
    
    func getRecordings() async {
        fetchStarted()
        
        let result = await getRecordingsUseCase.execute(for: (self.data?.id).orEmpty())
        
        switch result {
        case .success(let response):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.videos = response.data ?? []
                self?.currentVideo.meetingId = self?.data?.id
                self?.currentVideo.title = (self?.data?.title).orEmpty()
                self?.currentVideo.description = (self?.data?.description).orEmpty()
                self?.thumbnails = (response.data ?? []).compactMap({
                    self?.createThumbnail(url: URL(string: $0.downloadUrl.orEmpty()) ?? (NSURL() as URL))
                })
                self?.isShowImagePicker = (response.data ?? []).compactMap({_ in 
                    false
                })
            }
        case .failure(let error):
            handleDefaultError(error: error)
        }
    }
    
    func routeToCreatorStudio() {
        let viewModel = CreatorStudioViewModel(backToHome: self.backToHome)
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .creatorStudio(viewModel: viewModel)
        }
    }
    
    func showHoverVideo(_ urlString: String) {
        DispatchQueue.main.async { [weak self] in
            self?.currentVideo.videoUrl = urlString
            
            withAnimation {
                self?.isShowHoverVideo = true
            }
        }
    }
    
    func handleDefaultError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            self?.isLoadingUpload = false
            
            if let error = error as? ErrorResponse {
                
                self?.isError = true
                
                if error.statusCode.orZero() == 401 {
                    self?.error = LocaleText.sessionExpireText
                    self?.isRefreshFailed.toggle()
                } else {
                    self?.error = error.message.orEmpty()
                }
            } else {
                self?.isError = true
                self?.error = error.localizedDescription
            }
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
    
    @MainActor
    func archive() async {
        self.isLoadingArchieve = true
        self.isError = false
        self.error = ""
        
        let result = await archiveRecordUseCase.execute(with: (data?.id).orEmpty())
        
        switch result {
        case .success(_):
            DispatchQueue.main.async {[weak self] in
                self?.isLoadingArchieve = false
                
                self?.routeToCreatorStudio()
            }
        case .failure(let error):
           handleDefaultError(error: error)
        }
    }
    
    @MainActor
    func uploadCover(_ index: Int) async {
        self.isLoadingUpload = true
        self.isError = false
        self.error = ""
        
        let result = await uploadImageUseCase.execute(with: self.thumbnails[index])
        
        switch result {
        case .success(let response):
            
            self.currentVideo.cover = response
            await postVideo(self.currentVideo)
        case .failure(let error):
            handleDefaultError(error: error)
        }
    }
    
    @MainActor
    func postVideo(_ body: VideosRequest) async {
        
        print(body)
        let result = await postVideoUseCase.execute(with: body)
        
        switch result {
        case .success(_):
            DispatchQueue.main.async { [weak self] in
                self?.isLoadingUpload = false
                self?.currentVideo = .init(cover: "", title: "", description: "", videoUrl: "", meetingId: nil, audienceType: ViewerType.publicly.type)
                
                self?.routeToCreatorStudio()
            }
        case .failure(let error):
            handleDefaultError(error: error)
        }
    }
    
    func routeToRoot() {
        NavigationUtil.popToRootView()
        self.stateObservable.userType = 0
        self.stateObservable.isVerified = ""
        self.stateObservable.refreshToken = ""
        self.stateObservable.accessToken = ""
        self.stateObservable.isAnnounceShow = false
        OneSignal.setExternalUserId("")
    }
}
