//
//  FeedbackViewModel.swift
//  DinotisApp
//
//  Created by Irham Naufal on 15/08/23.
//

import Foundation
import DinotisDesignSystem
import DinotisData

final class FeedbackViewModel: ObservableObject {
    
    private let meetingId: String
    
    private let getReasonsUseCase: GetReasonsUseCase
    private let giveReviewUseCase: GiveReviewUseCase
    private let getDetailMeetingUseCase: GetMeetingDetailUseCase
    
    var backToHome: () -> Void
    var backToScheduleDetail: () -> Void
    
    @Published var route: HomeRouting? = nil
    @Published var detail: MeetingDetailResponse?
    
    @Published var rating: Int = 0
    
    @Published var chips0 = [ChipModel]()
    @Published var chips2 = [ChipModel]()
    @Published var chips3 = [ChipModel]()
    @Published var chips4 = [ChipModel]()
    @Published var chips5 = [ChipModel]()
    
    @Published var reasons: [String] = []
    @Published var feedback = ""
    
    @Published var isLoading = false
    @Published var isSuccess = false
    
    init(
        meetingId: String,
        getReasonsUseCase: GetReasonsUseCase = GetReasonsDefaultUseCase(),
        giveReviewUseCase: GiveReviewUseCase = GiveReviewDefaultUseCase(),
        getDetailMeetingUseCase: GetMeetingDetailUseCase = GetMeetingDetailDefaultUseCase(),
        backToHome: @escaping (() -> Void),
        backToScheduleDetail: @escaping () -> Void
    ) {
        self.meetingId = meetingId
        self.getReasonsUseCase = getReasonsUseCase
        self.giveReviewUseCase = giveReviewUseCase
        self.getDetailMeetingUseCase = getDetailMeetingUseCase
        self.backToHome = backToHome
        self.backToScheduleDetail = backToScheduleDetail
    }
    
    func disableButton() -> Bool {
        guard rating != 0 else { return true }
        if rating > 3 {
            return false
        } else {
            return feedback.isStringContainWhitespaceAndText() ? false : true
        }
    }
    
    func onGetDetail() {
        Task {
            await getDetailMeeting()
        }
    }
    
    func onGetReason(for rating: Int) {
        Task {
            await getReasons(rating: rating)
        }
    }
    
    func getDetailMeeting() async {
        let result = await getDetailMeetingUseCase.execute(for: meetingId)
        
        switch result {
        case .success(let response):
            DispatchQueue.main.async { [weak self] in
                self?.detail = response
            }
        case .failure(_):
            break
        }
    }
    
    func getReasons(rating: Int) async {
        
        switch rating {
        case 2:
            if chips2.isEmpty {
                let result = await getReasonsUseCase.execute(rating: rating)
                
                switch result {
                case .success(let response):
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self, let data = response.data else { return }
                        let value = data.compactMap { reason in
                            return ChipModel(isSelected: false, text: reason) {
                                self.reasons.append(reason)
                            }
                        }
                        self.chips2 = value
                    }
                case .failure(let error):
                    print(error)
                }
            }
            
        case 3:
            if chips3.isEmpty {
                let result = await getReasonsUseCase.execute(rating: rating)
                
                switch result {
                case .success(let response):
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self, let data = response.data else { return }
                        let value = data.compactMap { reason in
                            return ChipModel(isSelected: false, text: reason) {
                                self.reasons.append(reason)
                            }
                        }
                        self.chips3 = value
                    }
                case .failure(let error):
                    print(error)
                }
            }
            
        case 4:
            if chips4.isEmpty {
                let result = await getReasonsUseCase.execute(rating: rating)
                
                switch result {
                case .success(let response):
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self, let data = response.data else { return }
                        let value = data.compactMap { reason in
                            return ChipModel(isSelected: false, text: reason) {
                                self.reasons.append(reason)
                            }
                        }
                        self.chips4 = value
                    }
                case .failure(let error):
                    print(error)
                }
            }
            
        case 5:
            if chips5.isEmpty {
                let result = await getReasonsUseCase.execute(rating: rating)
                
                switch result {
                case .success(let response):
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self, let data = response.data else { return }
                        let value = data.compactMap { reason in
                            return ChipModel(isSelected: false, text: reason) {
                                self.reasons.append(reason)
                            }
                        }
                        self.chips5 = value
                    }
                case .failure(let error):
                    print(error)
                }
            }
            
        default:
            if chips0.isEmpty {
                let result = await getReasonsUseCase.execute(rating: rating)
                
                switch result {
                case .success(let response):
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self, let data = response.data else { return }
                        
                        let value = data.compactMap { reason in
                            return ChipModel(isSelected: false, text: reason) {
                                if let index = self.reasons.firstIndex(of: reason) {
                                    self.reasons.remove(at: index)
                                } else {
                                    self.reasons.append(reason)
                                }
                            }
                        }
                        self.chips0 = value
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func routeToSetUpVideo() {
        let viewModel = SetUpVideoViewModel(data: self.detail, backToHome: self.backToHome, backToScheduleDetail: self.backToScheduleDetail)
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .setUpVideo(viewModel: viewModel)
        }
    }
    
    func giveReview() async {
        
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = true
        }
        
        let body = ReviewRequestBody(
            rating: self.rating,
            review: self.feedback,
            meetingId: self.meetingId,
            isGeneral: true,
            reasons: self.reasons.joined(separator: ", ")
        )
        
        let result = await giveReviewUseCase.execute(with: body)
        
        switch result {
        case .success:
            DispatchQueue.main.async { [weak self] in
                self?.isSuccess = true
                self?.isLoading = false
            }
        case .failure(let error):
            print(error)
        }
    }
    
    func showArchived() -> Bool {
        (((detail?.endAt).orCurrentDate() < Date() || detail?.endedAt != nil) && (detail?.archiveRecording).orFalse() && !(detail?.isArchived ?? true))
    }
}
