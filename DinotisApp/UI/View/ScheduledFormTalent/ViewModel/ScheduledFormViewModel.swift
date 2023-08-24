//
//  ScheduledFormView.swift
//  DinotisApp
//
//  Created by Gus Adi on 26/02/22.
//

import Foundation
import SwiftUI
import OneSignal
import Combine
import DinotisData
import DinotisDesignSystem

final class ScheculedFormViewModel: ObservableObject {

	private let authRepository: AuthenticationRepository
	private let meetingRepository: MeetingsRepository
	private lazy var stateObservable = StateObservable.shared
	private var cancellables = Set<AnyCancellable>()
    private let userUseCase: GetUserUseCase
    private let addMeetingUseCase: CreateNewMeetingUseCase
	
	var backToHome: () -> Void

	@Published var colorTab = Color.clear

    @Published var managements: [ManagementWrappedData]?
	@Published var isLoading = false
	@Published var isError = false
	@Published var success = false
	@Published var error: String?

	@Published var minimumPeopleError = false

	@Published var isRefreshFailed = false

  @Published var meetingArr = [AddMeetingRequest(id: String.random(), title: "", description: "", price: 0, startAt: "", endAt: "", isPrivate: true, slots: 1, managementId: nil, urls: [])]

	@Published private var scrollViewContentOffset = CGFloat(0)
	
	init(
		backToHome: @escaping (() -> Void),
		meetingRepository: MeetingsRepository = MeetingsDefaultRepository(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
        userUseCase: GetUserUseCase = GetUserDefaultUseCase(),
        addMeetingUseCase: CreateNewMeetingUseCase = CreateNewMeetingDefaultUseCase()
	) {
		self.backToHome = backToHome
		self.meetingRepository = meetingRepository
		self.authRepository = authRepository
        self.userUseCase = userUseCase
        self.addMeetingUseCase = addMeetingUseCase
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
    
    func handleDefaultError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            
            if let error = error as? ErrorResponse {
                self?.error = error.message.orEmpty()
                
                
                if error.statusCode.orZero() == 401 {
                    self?.isRefreshFailed.toggle()
                } else {
                    self?.isError = true
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
                print("items manage:", success)
                self?.managements = success.managements
                self?.stateObservable.userId = success.id.orEmpty()
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }

	func submitMeeting() {
		if meetingArr.contains(where: {
			$0.title.isEmpty || $0.description.isEmpty
		}) {
			isError.toggle()
			error = LocaleText.formFieldError
		} else if meetingArr.contains(where: {
			!$0.isPrivate && $0.slots <= 1
		}) {
			minimumPeopleError.toggle()
		} else {
			for items in meetingArr.indices {
				if meetingArr[items].endAt.isEmpty && meetingArr[items].startAt.isEmpty {
                    meetingArr[items].endAt = DateUtils.dateFormatter(Date().addingTimeInterval(7200), forFormat: .utcV2)

                    meetingArr[items].startAt = DateUtils.dateFormatter(Date().addingTimeInterval(3600), forFormat: .utcV2)
                    onCreateMeeting(with: meetingArr[items])
                } else if meetingArr[items].endAt.isEmpty {
                    let time = DateUtils.dateFormatter(meetingArr[items].startAt, forFormat: .utcV2)
                    meetingArr[items].endAt = DateUtils.dateFormatter(time.addingTimeInterval(3600), forFormat: .utcV2)
                    onCreateMeeting(with: meetingArr[items])
                    
                } else if meetingArr[items].startAt.isEmpty {
                    meetingArr[items].endAt = DateUtils.dateFormatter(Date().addingTimeInterval(7200), forFormat: .utcV2)

                    meetingArr[items].startAt = DateUtils.dateFormatter(Date().addingTimeInterval(3600), forFormat: .utcV2)
                    onCreateMeeting(with: meetingArr[items])
				} else {
                    onCreateMeeting(with: meetingArr[items])
				}
			}
		}
	}

	func onStartRequest() {
		DispatchQueue.main.async {[weak self] in
			self?.isLoading = true
			self?.isError = false
			self?.error = nil
			self?.success = false
			self?.isRefreshFailed = false
		}

	}
    
    func onCreateMeeting(with meeting: AddMeetingRequest) {
        Task {
            await addMeeting(meeting: meeting)
        }
    }

	func addMeeting(meeting: AddMeetingRequest) async {
		onStartRequest()
        
        let result = await addMeetingUseCase.execute(from: meeting)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false

                if meeting.id == (self?.meetingArr.last?.id).orEmpty() {
                    self?.success = true
                }
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
	}
}
