//
//  CreatorStudioViewModel.swift
//  DinotisApp
//
//  Created by Irham Naufal on 30/10/23.
//

import AVFoundation
import DinotisData
import DinotisDesignSystem
import SwiftUI
import Moya

enum StudioVideoFilter: String, Codable {
    case archive = "ARCHIEVE"
}

enum UploadState {
    case initial, select, uploading, success, failed
}

final class CreatorStudioViewModel: ObservableObject {
    
    private let uploadSignedVideoUseCase: VideoSignedUseCase
    private let putSignedVideoUseCase: PutVideoSignedURLUseCase
    private let uploadImageUseCase: SinglePhotoUseCase
    private let postVideoUseCase: PostVideoUseCase
    private let getUserUseCase: GetUserUseCase
    private let getMineVideoUseCase: GetMineVideoUseCase
    private let deleteVideoUseCase: DeleteVideoUseCase
    private let editVideoUseCase: EditVideoItemUseCase
    private let getDetailVideoUseCase: GetDetailVideoUseCase
    private let getArchivedUseCase: GetArchivedUseCase
    
    @Published var isEdit = false
    @Published var route: HomeRouting?
    
    @Published var isShowDelete = false
    @Published var selectedId: String? = nil
    
    @Published var mineVideoRequest = MineVideoRequest()
    @Published var skipArchived = 0
    @Published var takeArchived = 5
    
    @Published var profileImage = ""
    
    @Published var uploadProgress: Float = 0.0
    
    @Published var isShowPicker = false
    @Published var isShowImagePicker = false
    @Published var isShowPostEditor = false
    @Published var isShowHoverVideo = false
    @Published var isShowUploadSheet = false
    @Published var isShowCancelUploadSheet = false
    
    @Published var uploadState: UploadState = .initial
    
    @Published var currentVideo: VideosRequest = .init(cover: "", title: "", description: "", videoUrl: "", meetingId: nil, audienceType: ViewerType.publicly.type)
    @Published var selectedVideo: URL? = nil
    @Published var thumbnail = UIImage()
    
    @Published var videos = [MineVideoData]()
    
    @Published var isLoadingMore = false
    @Published var isLoading = false
    @Published var isError = false
    @Published var isRefreshFailed = false
    @Published var error = ""
    
    @Published var isLoadingEdit = false
    @Published var isErrorEdit = false
    @Published var errorEdit = ""
    
    @Published var nextCursor: Int? = nil
    
    @Published var archivedVideo = [ArchivedData]()
    
    @Published var currentSection: String = "desc"
    @Published var sections: [MineVideoVideoType] = [.RECORD]
    @Published var sortSections: [MineVideoSorting] = [.desc, .asc]
    @Published var archieveSections: [StudioVideoFilter] = [.archive]
    
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
    
    init(
        backToHome: @escaping () -> Void,
        uploadSignedVideoUseCase: VideoSignedUseCase = VideoSignedDefaultUseCase(),
        putSignedVideoUseCase: PutVideoSignedURLUseCase = PutVideoSignedURLDefaultUseCase(),
        uploadImageUseCase: SinglePhotoUseCase = SinglePhotoDefaultUseCase(),
        postVideoUseCase: PostVideoUseCase = PostVideoDefaultUseCase(),
        getUserUseCase: GetUserUseCase = GetUserDefaultUseCase(),
        getMineVideoUseCase: GetMineVideoUseCase = GetMineVideoDefaultUseCase(),
        deleteVideoUseCase: DeleteVideoUseCase = DeleteVideoDefaultUseCase(),
        editVideoUseCase: EditVideoItemUseCase = EditVideoItemDefaultUseCase(),
        getDetailVideoUseCase: GetDetailVideoUseCase = GetDetailVideoDefaultUseCase(),
        getArchivedUseCase: GetArchivedUseCase = GetArchivedDefaultUseCase()
    ) {
        self.backToHome = backToHome
        self.uploadSignedVideoUseCase = uploadSignedVideoUseCase
        self.putSignedVideoUseCase = putSignedVideoUseCase
        self.uploadImageUseCase = uploadImageUseCase
        self.postVideoUseCase = postVideoUseCase
        self.getUserUseCase = getUserUseCase
        self.getMineVideoUseCase = getMineVideoUseCase
        self.deleteVideoUseCase = deleteVideoUseCase
        self.editVideoUseCase = editVideoUseCase
        self.getDetailVideoUseCase = getDetailVideoUseCase
        self.getArchivedUseCase = getArchivedUseCase
    }
    
    func chipText(_ section: String) -> String {
        switch section {
        case MineVideoSorting.asc.rawValue:
            LocalizableText.sortEarliest
        case MineVideoSorting.desc.rawValue:
            LocalizableText.sortLatest
        case MineVideoVideoType.RECORD.rawValue:
            LocalizableText.recordedLabel
        case StudioVideoFilter.archive.rawValue:
            LocalizableText.archiveLabel
        default:
            ""
        }
    }
    
    func fetchStartedList(isMore: Bool) {
        DispatchQueue.main.async { [weak self] in
            if isMore {
                self?.isLoadingMore = true
            } else {
                self?.isLoading = true
            }
            
            self?.isError = false
            self?.isRefreshFailed = false
            self?.error = ""
        }
    }
    
    func onEditStart() {
        DispatchQueue.main.async { [weak self] in
            self?.isLoadingEdit = true
            
            self?.isErrorEdit = false
            self?.isRefreshFailed = false
            self?.errorEdit = ""
        }
    }
    
    func viewerTypeText(_ type: String) -> String {
        switch type {
        case ViewerType.publicly.type:
            LocalizableText.publicLabel
        case ViewerType.subscriber.type:
            LocalizableText.subscriberLabel
        default:
            LocalizableText.publicLabel
        }
    }
    
    func dateFormatter(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, yyyy"
        return formatter.string(from: date)
    }
    
    func editVideo(_ video: MineVideoData) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.isEdit = true
            self.currentVideo = .init(cover: video.cover.orEmpty(), title: video.title.orEmpty(), description: video.description.orEmpty(), videoUrl: video.videoUrl.orEmpty(), meetingId: video.meetingId, audienceType: (video.audienceType?.rawValue).orEmpty())
            self.isShowPostEditor = true
        }
    }
    
    func editVideoItem(id: String, for body: VideosRequest) async {
        if thumbnail == UIImage() {
            onEditStart()
        }
        
        let result = await editVideoUseCase.execute(for: id, with: body)
        
        switch result {
        case .success(_):
            DispatchQueue.main.async { [weak self] in
                self?.isLoadingEdit = false
                self?.dismissEditor()
                
                self?.thumbnail = UIImage()
                self?.mineVideoRequest.skip = 0
                self?.mineVideoRequest.take = 5
                self?.onLoadMineVideo()
            }
        case .failure(let error):
            handleDefaultErrorEdit(error: error)
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
        if let url = selectedVideo, uploadState == .select {
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
            self?.isEdit = false
            self?.uploadState = .initial
            self?.currentVideo = .init(cover: "", title: "", description: "", videoUrl: "", meetingId: "", audienceType: "")
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
    
    func startUpload() async {
        DispatchQueue.main.async { [weak self] in
            self?.isShowPostEditor = false
            self?.uploadState = .uploading
        }
        
        if let url = self.selectedVideo, let data = try? Data(contentsOf: url) {
            await self.uploadVideo(data)
        }
    }
    
    func disablePostButton() -> Bool {
        currentVideo.title.count < 5 || currentVideo.description.count < 5
    }
    
    func routeToSessionRecordingList(videos: [RecordingData]) {
        let viewModel = SessionRecordingListViewModel(videos: videos, backToHome: { self.backToHome() })
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .sessionRecordingList(viewModel: viewModel)
        }
    }
    
    func routeToDetailVideo(id: String) {
        let viewModel = DetailVideoViewModel(videoId: id,backToHome: { self.backToHome() })
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .detailVideo(viewModel: viewModel)
        }
    }
    
    @MainActor
    func uploadVideo(_ video: Data) async {
        
        let result = await uploadSignedVideoUseCase.execute(with: "mov")
        
        switch result {
        case .success(let response):
            self.uploadProgress = 1/4
            await uploadBySignedURL(video, response: response)
        case .failure(let error):
            DispatchQueue.main.async { [weak self] in
                self?.uploadState = .failed
                self?.currentVideo = .init(cover: "", title: "", description: "", videoUrl: "", meetingId: "", audienceType: ViewerType.publicly.type)
                self?.thumbnail = UIImage()
            }
            
            if let error = error as? ErrorResponse {
                print("\(error)")
            } else {
                print("\(error)")
            }
        }
    }
    
    @MainActor
    func uploadCoverEdit(_ image: UIImage) async {
        onEditStart()
        
        let result = await uploadImageUseCase.execute(with: image)
        
        switch result {
        case .success(let response):
            await changeCover(url: response)
        case .failure(let error):
            handleDefaultError(error: error)
        }
    }
    
    @MainActor
    func changeCover(url: String) async {
        self.currentVideo.cover = url
    }
    
    @MainActor
    func uploadCover(_ image: UIImage) async {
        
        let result = await uploadImageUseCase.execute(with: image)
        
        switch result {
        case .success(let response):
            DispatchQueue.main.async { [weak self] in
                self?.uploadProgress = 3/4
            }
            
            self.currentVideo.cover = response
            await postVideo(self.currentVideo)
        case .failure(let error):
            DispatchQueue.main.async { [weak self] in
                self?.uploadState = .failed
                self?.currentVideo = .init(cover: "", title: "", description: "", videoUrl: "", meetingId: "", audienceType: ViewerType.publicly.type)
                self?.thumbnail = UIImage()
            }
            
            if let error = error as? ErrorResponse {
                print("\(error)")
            } else {
                print("\(error)")
            }
        }
    }
    
    @MainActor
    func postVideo(_ body: VideosRequest) async {
        
        print(body)
        let result = await postVideoUseCase.execute(with: body)
        
        switch result {
        case .success(_):
            DispatchQueue.main.async { [weak self] in
                self?.uploadProgress = 4/4
                self?.uploadState = .success
                self?.currentVideo = .init(cover: "", title: "", description: "", videoUrl: "", meetingId: nil, audienceType: ViewerType.publicly.type)
                self?.thumbnail = UIImage()
                self?.onLoadMineVideo()
                
                self?.mineVideoRequest.skip = 0
                self?.mineVideoRequest.take = 5
                self?.videos = []
                
                self?.onLoadMineVideo()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                withAnimation {
                    self?.uploadState = .initial
                    self?.uploadProgress = 0.0
                }
            }
        case .failure(let error):
            DispatchQueue.main.async { [weak self] in
                self?.uploadState = .failed
                self?.currentVideo = .init(cover: "", title: "", description: "", videoUrl: "", meetingId: nil, audienceType: ViewerType.publicly.type)
                self?.thumbnail = UIImage()
            }
            
            if let error = error as? ErrorResponse {
                print("\(error)")
            } else {
                print("\(error)")
            }
        }
    }
    
    func uploadBySignedURL(_ video: Data, response: UploadVideoSignedResponse) async {
        let result = await putSignedVideoUseCase.execute(
            baseURL: response.baseUrl.orEmpty(),
            path: response.path.orEmpty(),
            params: response.queryParams ?? QueryParamsData(),
            header: response.headers ?? HeaderData(),
            video: video,
            ext: "mov"
        ) { progress in
            self.uploadProgress = Float(progress.progress)
        }
        
        switch result {
        case .success(_):
            
            DispatchQueue.main.async { [weak self] in
                self?.uploadProgress = 2/4
                self?.currentVideo.videoUrl = response.publicUrl.orEmpty()
                
            }
            
            await uploadCover(thumbnail)
        case .failure(let error):
            
            DispatchQueue.main.async { [weak self] in
                self?.uploadState = .failed
                self?.currentVideo = .init(cover: "", title: "", description: "", videoUrl: "", meetingId: nil, audienceType: ViewerType.publicly.type)
                self?.thumbnail = UIImage()
            }
            if let error = error as? ErrorResponse {
                print("\(error)")
            } else {
                print("\(error)")
            }
        }
    }
    
    func getUser() async {
        let result = await getUserUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.profileImage = success.profilePhoto.orEmpty()
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    func onLoadUser() {
        SwiftUI.Task {
            await getUser()
        }
    }
    
    func onLoadMineVideo() {
        SwiftUI.Task {
            await getMineVideo(isMore: false)
        }
    }
    
    func onLoadArchivedVideo() {
        SwiftUI.Task {
            await getArchived(isMore: false)
        }
    }
    
    func getMineVideo(isMore: Bool) async {
        fetchStartedList(isMore: isMore)
        
        let result = await getMineVideoUseCase.execute(with: mineVideoRequest)
        
        switch result {
        case .success(let response):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.isLoadingMore = false
                
                if isMore {
                    self?.videos += (response.data ?? [])
                } else {
                    self?.videos = (response.data ?? [])
                }
                
                self?.nextCursor = response.nextCursor
            }
        case .failure(let error):
            handleDefaultError(error: error)
        }
    }
    
    func getArchived(isMore: Bool) async {
        fetchStartedList(isMore: isMore)
        
        let result = await getArchivedUseCase.execute(skip: skipArchived, take: takeArchived)
        
        switch result {
        case .success(let response):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.isLoadingMore = false
                
                if isMore {
                    self?.archivedVideo += (response.data ?? [])
                } else {
                    self?.archivedVideo = (response.data ?? [])
                }
                
                self?.nextCursor = response.nextCursor
            }
        case .failure(let error):
            handleDefaultError(error: error)
        }
    }
    
    func deleteVideo(id: String) async {
        fetchStartedList(isMore: false)
        
        let result = await deleteVideoUseCase.execute(for: id)
        
        switch result {
        case .success(_):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                
                self?.mineVideoRequest.skip = 0
                self?.mineVideoRequest.take = 5
                self?.onLoadMineVideo()
            }
        case .failure(let error):
            handleDefaultError(error: error)
        }
    }
    
    func handleDefaultError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            
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
    
    func handleDefaultErrorEdit(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoadingEdit = false
            
            if let error = error as? ErrorResponse {
                
                self?.isErrorEdit = true
                
                if error.statusCode.orZero() == 401 {
                    self?.errorEdit = LocaleText.sessionExpireText
                    self?.isRefreshFailed.toggle()
                } else {
                    self?.errorEdit = error.message.orEmpty()
                }
            } else {
                self?.isErrorEdit = true
                self?.errorEdit = error.localizedDescription
            }
        }
        
    }
}
