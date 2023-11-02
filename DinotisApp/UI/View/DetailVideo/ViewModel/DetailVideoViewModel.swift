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
    
    @Published var userData: UserResponse?
    @Published var meetingData = [MeetingDetailResponse]()
    @Published var videoData: DummyVideoModel = .init(
        title: "Lorem ipsum dolor sit amet consectetur. Aliquet vitae id pellentesque est ",
        description: "Lorem ipsum dolor sit amet consectetur. Mattis et ut fusce eget turpis in tellus sit. Ultrices est rhoncus vestibulum lectus non. Dui duis etiam dictum quam ut condimentum lacinia. Lorem egestas duis in sollicitudin diam in nec. Eu tincidunt ultricies et id semper erat morbi sed urna. Viverra pulvinar ultrices viverra nisi ac et viverra. Habitasse quis et volutpat dolor lectus aliquet.",
        thumbnail: "https://esports.id/img/article/854920211125095801.jpg",
        comments: [.init(name: "Ahmad Deni"), .init(name: "Baharudin"), .init(name: "Salsabilla Adriani"), .init(name: "Nabila Smith"), .init(name: "Basuki")]
    )
    
    @Published var route: HomeRouting?
    
    @Published var commentText = ""
    @Published var currentSection = 1
    
    @Published var isShowBottomSheet = false
    
    @Published var isError: Bool = false
    @Published var error: String?
    @Published var success: Bool = false
    @Published var isLoading = false
    
    @Published var isShowFullText = false
    
    var backToHome: () -> Void
    
    var professionText: String? {
        (userData?.stringProfessions?.joined(separator: ", "))
    }
    
    init(
        getUserUseCase: GetUserUseCase = GetUserDefaultUseCase(),
        getTalentMeetingUseCase: GetCreatorMeetingListUseCase = GetCreatorMeetingListDefaultUseCase(),
        backToHome: @escaping () -> Void
    ) {
        self.getUserUseCase = getUserUseCase
        self.getTalentMeetingUseCase = getTalentMeetingUseCase
        self.backToHome = backToHome
    }
    
    func onStartedFetch() {
        DispatchQueue.main.async {[weak self] in
            self?.isError = false
            self?.isLoading = true
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
    
    func getUsers() async {
        onStartedFetch()
        
        let result = await getUserUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoading = false
                
                self?.userData = success

                OneSignal.setExternalUserId(success.id.orEmpty())
                OneSignal.sendTag("isTalent", value: "true")
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    func getTalentMeeting() async {
        onStartedFetch()

        let result = await getTalentMeetingUseCase.execute(with: .init(take: 15, skip: 0, isStarted: "", isEnded: "false", isAvailable: "true"))
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoading = false
                self?.meetingData = success.data?.meetings ?? []
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    func handleDefaultError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false

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
    
    func addComment() {
        let comment: DummyCommentModel = .init(
            name: (userData?.name).orEmpty(),
            profileImage: (userData?.profilePhoto).orEmpty(),
            comment: commentText,
            date: .now
        )
        DispatchQueue.main.async { [weak self] in
            self?.videoData.comments.append(comment)
            self?.commentText = ""
        }
    }
    
    func disableSendButton() -> Bool {
        commentText.isEmpty || !commentText.isStringContainWhitespaceAndText()
    }
}
