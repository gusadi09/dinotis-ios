//
//  DetailVideoViewModel.swift
//  DinotisApp
//
//  Created by Irham Naufal on 01/11/23.
//

import DinotisDesignSystem
import SwiftUI
import DinotisData
import OneSignal

struct DummyVideoModel: Identifiable {
    var id: UUID = .init()
    var title: String
    var description: String = ""
    var url: URL? = URL(string: "https://storage.googleapis.com/dinotis-recording-1/recordings/bbb789d0-f056-4c89-b936-7bd5051c72b4_1697192142005.mp4")
    var thumbnail: String
    var date: Date = .now
    var type: String = LocalizableText.recordedLabel
    var viewerType: ViewerType = .publicly
    var comments: [DummyCommentModel] = []
    var commentCount: Int {
        comments.count
    }
}

struct DummyCommentModel: Identifiable {
    var id: UUID = .init()
    var name: String
    var profileImage: String = "https://img.wattpad.com/cover/74721931-256-k573169.jpg"
    var comment: String = "Lorem ipsum dolor sit amet consectetur. Sodales leo leo ac feugiat sit. Cursus dictum nulla vel malesuada tellus faucibus. In imperdiet lobortis laoreet viverra feugiat. Id auctor odio malesuada et purus vitae dui at. Odio quis aenean aliquam velit nisi"
    var date: Date = .now
}

final class DetailVideoViewModel: ObservableObject {
    
    private let getUserUseCase: GetUserUseCase
    private let getTalentMeetingUseCase: GetCreatorMeetingListUseCase
    private let getDetailVideoUseCase: GetDetailVideoUseCase
    private let postCommentUseCase: PostCommentUseCase
    private let getCommentsUseCase: GetCommentsUseCase
    let videoId: String
    
    @Published var userData: UserResponse?
    @Published var state = StateObservable.shared
    @Published var meetingData = [MeetingDetailResponse]()
    @Published var videoData: DetailVideosResponse?
    @Published var comments = [GeneralComments]()
    
    @Published var videoUrl: String?
    
    @Published var route: HomeRouting?
    
    @Published var commentText = ""
    @Published var currentSection = 1
    
    @Published var isShowBottomSheet = false
    
    @Published var isError: Bool = false
    @Published var error: String?
    @Published var success: Bool = false
    @Published var isLoading = false
    
    @Published var isLoadingComment = false
    @Published var isLoadingMoreComment = false
    @Published var takeComment = 10
    @Published var skipComment = 0
    
    @Published var isLoadingSend = false
    
    @Published var nextCursor: Int? = 0
    
    @Published var isShowFullText = false
    
    var backToHome: () -> Void
    
    var professionText: String? {
        (videoData?.video?.user?.professions?.joined(separator: ", "))
    }
    
    init(
        getUserUseCase: GetUserUseCase = GetUserDefaultUseCase(),
        getTalentMeetingUseCase: GetCreatorMeetingListUseCase = GetCreatorMeetingListDefaultUseCase(),
        getDetailVideoUseCase: GetDetailVideoUseCase = GetDetailVideoDefaultUseCase(),
        postCommentUseCase: PostCommentUseCase = PostCommentDefaultUseCase(),
        getCommentsUseCase: GetCommentsUseCase = GetCommentsDefaultUseCase(),
        videoId: String,
        backToHome: @escaping () -> Void
    ) {
        self.getUserUseCase = getUserUseCase
        self.getTalentMeetingUseCase = getTalentMeetingUseCase
        self.getDetailVideoUseCase = getDetailVideoUseCase
        self.postCommentUseCase = postCommentUseCase
        self.getCommentsUseCase = getCommentsUseCase
        self.videoId = videoId
        self.backToHome = backToHome
    }
    
    func onStartedFetch(isComment: Bool = false, isMore: Bool = false, isSended: Bool = false) {
        DispatchQueue.main.async {[weak self] in
            if !isSended {
                if isComment {
                    if isMore {
                        self?.isLoadingMoreComment = true
                    } else {
                        self?.isLoadingComment = true
                    }
                } else {
                    self?.isLoading = true
                }
            }
            
            self?.isError = false
            
            self?.error = nil
            self?.success = false
        }
    }
    
    func onStartedSend() {
        DispatchQueue.main.async {[weak self] in
            self?.isLoadingSend = true
            self?.isError = false
            
            self?.error = nil
            self?.success = false
        }
    }
    
    func dateFormatter(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, yyyy"
        return formatter.string(from: date)
    }
    
    func sectionText(_ section: Int) -> String {
        switch section {
        case 2:
            LocalizableText.privateVideoCallLabel
        default:
            LocalizableText.groupVideoCallLabel
        }
    }
    
    func getDetailVideo() async {
        onStartedFetch()
        
        let result = await getDetailVideoUseCase.execute(for: videoId)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoading = false
                
                self?.videoData = success
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: .init(block: { [weak self] in
                    self?.videoUrl = success.video?.videoUrl
                }))
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
//    func onGetMeeting() {
//        Task {
//            await getTalentMeeting()
//        }
//    }
    
    func onGetDetail() {
        Task {
            await getDetailVideo()
        }
    }
    
    func onGetUser() {
        Task {
            await getUsers()
        }
    }
    
//    func getTalentMeeting() async {
//        onStartedFetch()
//
//        let result = await getTalentMeetingUseCase.execute(with: .init(take: 15, skip: 0, isStarted: "", isEnded: "false", isAvailable: "true"))
//
//        switch result {
//        case .success(let success):
//            DispatchQueue.main.async { [weak self] in
//                self?.success = true
//                self?.isLoading = false
//                self?.meetingData = success.data?.meetings ?? []
//            }
//        case .failure(let failure):
//            handleDefaultError(error: failure)
//        }
//    }
    
    func getUsers() async {
        let result = await getUserUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                
                self?.userData = success
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    func handleDefaultError(error: Error, isComment: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            self?.isLoadingMoreComment = false
            self?.isLoadingComment = false
            self?.isLoadingSend = false

            if let error = error as? ErrorResponse {

                if error.statusCode.orZero() == 401 {
                    self?.error = error.message.orEmpty()
                } else {
                    self?.error = error.message.orEmpty()
                    self?.isError = true
                }
            } else {
                self?.isError = true
                self?.error = error.localizedDescription
            }
        }
    }
    
    func disableSendButton() -> Bool {
        commentText.isEmpty || !commentText.isStringContainWhitespaceAndText() || isLoadingSend
    }
    
    @MainActor func shareSheet(url: String) {
        
        guard let url = URL(string: url) else { return }
        let activityView = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        if let rootVC = UIApplication.shared.windows.first?.rootViewController {
            DispatchQueue.main.async {
                rootVC.present(activityView, animated: true) {}
            }
            
        }
        
    }
    
    func getComments(isMore: Bool, isSended: Bool = false) async {
        
        onStartedFetch(isComment: true, isMore: isMore, isSended: isSended)
        
        let result = await getCommentsUseCase.execute(for: videoId, skip: skipComment, take: takeComment)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.isLoadingMoreComment = false
                self?.isLoadingComment = false
                
                if isMore {
                    self?.comments += (success.data ?? [])
                } else {
                    self?.comments = success.data ?? []
                }
                
                self?.nextCursor = success.nextCursor
            }
        case .failure(let error):
            handleDefaultError(error: error, isComment: true)
        }
    }
    
    func onAppearGetComments() {
        Task {
            await getComments(isMore: false, isSended: false)
        }
    }
    
    func postComments() async {
        onStartedSend()
        
        let result = await postCommentUseCase.execute(for: videoId, comment: commentText)
        
        switch result {
        case .success(_):
            DispatchQueue.main.async { [weak self] in
                self?.isLoadingSend = false
                self?.commentText = ""
            }
            
            self.skipComment = 0
            self.takeComment = 10
            await self.getComments(isMore: false, isSended: true)
        case .failure(let failure):
            handleDefaultError(error: failure, isComment: true)
        }
    }
}
