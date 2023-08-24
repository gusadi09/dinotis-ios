//
//  EditTalentMeetingViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 07/11/22.
//

import Foundation
import Combine
import OneSignal
import UIKit
import DinotisData
import DinotisDesignSystem

final class EditTalentMeetingViewModel: ObservableObject {

	var backToHome: () -> Void

	private lazy var stateObservable = StateObservable.shared

	private var cancellables = Set<AnyCancellable>()
    private let getDetailMeetingUseCase: GetMeetingDetailUseCase
	private let authRepository: AuthenticationRepository
	private let meetingRepository: MeetingsRepository
    private let userUseCase: GetUserUseCase
    private let editMeetingUseCase: EditCreatorMeetingUseCase
	private var onValueChanged: ((_ refreshControl: UIRefreshControl) -> Void)?

	@Published var isLoading = false
	@Published var isError = false
	@Published var success = false
	@Published var error: String?
    @Published var managements: [ManagementWrappedData]?

	@Published var meetingID: String
    
    @Published var isShowSuccess = false
    @Published var isDisableEdit = false
    @Published var talent = [MeetingCollaborationData]()
    @Published var maxEdit = 0
    
    @Published var meetingForm = AddMeetingRequest(id: "", title: "", description: "", price: 0, startAt: "", endAt: "", isPrivate: false, slots: 0, managementId: nil, urls: [])
    
    @Published var isRefreshFailed = false
    
    init(
		meetingID: String,
		backToHome: @escaping (() -> Void),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
		meetingRepository: MeetingsRepository = MeetingsDefaultRepository(),
        userUseCase: GetUserUseCase = GetUserDefaultUseCase(),
        getDetailMeetingUseCase: GetMeetingDetailUseCase = GetMeetingDetailDefaultUseCase(),
        editMeetingUseCase: EditCreatorMeetingUseCase = EditCreatorMeetingDefaultUseCase()
	) {
		self.meetingID = meetingID
		self.backToHome = backToHome
		self.authRepository = authRepository
		self.meetingRepository = meetingRepository
        self.userUseCase = userUseCase
        self.getDetailMeetingUseCase = getDetailMeetingUseCase
        self.editMeetingUseCase = editMeetingUseCase
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

	func onStartRequest() {
		DispatchQueue.main.async {[weak self] in
			self?.isLoading = true
			self?.isError = false
			self?.error = nil
			self?.isRefreshFailed = false
			self?.isShowSuccess = false
		}

	}
    
    func handleDefaultError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            
            if let error = error as? ErrorResponse {
                
                if error.statusCode.orZero() == 401 {
                    self?.isRefreshFailed.toggle()
                    self?.error = error.message.orEmpty()
                } else if error.statusCode.orZero() == 422 {
                    self?.isError = true

                    self?.error = LocaleText.formFieldError
                } else {
                    self?.isError = true
                    self?.error = error.message.orEmpty()
                }
            } else {
                self?.isError = true
                self?.error = error.localizedDescription
            }
            
        }
    }
    
    func getUsers() async {
        onStartRequest()
        
        let result = await userUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.managements = success.managements
                self?.stateObservable.userId = success.id.orEmpty()
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }

    func onGetUser() {
        Task {
            await getUsers()
        }
    }
    
    func onGetMeetingDetail() {
        Task {
            await getMeetingDetail()
        }
    }
    
    func onAppear() {
        onGetUser()
        onGetMeetingDetail()
    }
    
	func getMeetingDetail() async {
		onStartRequest()

        let result = await getDetailMeetingUseCase.execute(for: self.meetingID)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.meetingForm.id = success.id
                self?.meetingForm.description = success.description.orEmpty()
                self?.meetingForm.endAt = DateUtils.dateFormatter(success.endAt.orCurrentDate(), forFormat: .utcV2)
                self?.meetingForm.isPrivate = success.isPrivate ?? false
                self?.meetingForm.price = Int(success.price.orEmpty()).orZero()
                self?.meetingForm.slots = success.slots.orZero()
                self?.meetingForm.startAt = DateUtils.dateFormatter(success.startAt.orCurrentDate(), forFormat: .utcV2)
                self?.meetingForm.title = success.title.orEmpty()
                self?.meetingForm.managementId = success.managementId
                
                if let startAt = success.startAt, let maxEdit = success.maxEditAt {
                    self?.toggleDisableEdit(from: maxEdit)
                    self?.maxEdit = (self?.minuteDifferenceOfMaxEdit(with: maxEdit, from: startAt)).orZero()
                }
                
                self?.meetingForm.urls = success.meetingUrls?.compactMap({ value in
                    MeetingURLrequest(title: value.title.orEmpty(), url: value.url.orEmpty())
                }) ?? []
                
                self?.meetingForm.collaborations = success.meetingCollaborations?.compactMap({
                    $0.username
                })
                
                self?.talent = success.meetingCollaborations ?? []
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }

	func editMeeting() async {
		onStartRequest()
        
        let result = await editMeetingUseCase.execute(for: meetingID, with: meetingForm)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.isShowSuccess = true
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }

	}
    
    func toggleDisableEdit(from maxEdit: Date) {
        isDisableEdit = maxEdit < Date()
    }
    
    func minuteDifferenceOfMaxEdit(with maxEdit: Date, from start: Date) -> Int {
        
        var components1 = Calendar.current.dateComponents([.hour, .minute], from: start)
        
        let components2 = Calendar.current.dateComponents([.hour, .minute, .day, .month, .year], from: maxEdit)
        
        components1.year = components2.year;
        components1.month = components2.month;
        components1.day = components2.day;
        
        guard let date3 = Calendar.current.date(from: components1) else { return 0 }
        
        let timeIntervalInMinutes = date3.timeIntervalSince(maxEdit)/60
        
        return Int(timeIntervalInMinutes)
    }
    
    func disableSaveButton() -> Bool {
        (!meetingForm.urls.isEmpty && meetingForm.urls.allSatisfy({!$0.url.validateURL()})) || isDisableEdit
    }
}
